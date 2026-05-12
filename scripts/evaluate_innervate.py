"""Regenerate the Innervate sample-analysis artifacts for the Jekyll site.

This script intentionally keeps the original project small and inspectable. It
uses Innervate's own NumPy-only network implementation for the main model, but
uses scikit-learn for two reference baselines and for the stratified split.

Run from the repository root:
    python scripts/evaluate_innervate.py
"""
from __future__ import annotations

import csv
import os
import sys
from pathlib import Path
from typing import Iterable

import numpy as np

REPO = Path(__file__).resolve().parents[1]
os.environ.setdefault("MPLCONFIGDIR", str(REPO / ".matplotlib-cache"))

import matplotlib.pyplot as plt
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, balanced_accuracy_score, f1_score
from sklearn.model_selection import train_test_split
from sklearn.neighbors import KNeighborsClassifier

INNERVATE = REPO / "code" / "Innervate"
SRC = INNERVATE / "src"
sys.path.insert(0, str(SRC))

from core.activations import Sigmoid  # noqa: E402
from core.layers import Dense  # noqa: E402
from core.losses import MSE  # noqa: E402
from core.network import Network  # noqa: E402

FIG_DIR = REPO / "assets" / "figures"
DATA_DIR = REPO / "assets" / "data"
DOC_DIR = REPO / "assets" / "docs"
for directory in [FIG_DIR, DATA_DIR, DOC_DIR]:
    directory.mkdir(parents=True, exist_ok=True)

RANDOM_STATE = 42
TEST_SIZE = 0.20
EPOCHS = 100
LEARNING_RATE = 0.01


def write_rows(path: Path, rows: list[dict]) -> None:
    if not rows:
        raise ValueError(f"No rows supplied for {path}")
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


def load_parenthesized_matrix(path: Path) -> np.ndarray:
    rows = []
    with path.open("r", encoding="utf-8") as handle:
        for line in handle:
            stripped = line.strip().strip("()")
            if stripped:
                rows.append([float(x) for x in stripped.split(",")])
    return np.array(rows, dtype=float)


def new_network() -> Network:
    return Network([
        Dense(64, 20, Sigmoid()),
        Dense(20, 10, Sigmoid()),
    ])


def load_saved_network() -> Network:
    net = new_network()
    net._network[0].weights = load_parenthesized_matrix(INNERVATE / "output" / "weights_1.txt")
    net._network[0].biases = load_parenthesized_matrix(INNERVATE / "output" / "biases_1.txt").reshape(-1, 1)
    net._network[1].weights = load_parenthesized_matrix(INNERVATE / "output" / "weights_2.txt")
    net._network[1].biases = load_parenthesized_matrix(INNERVATE / "output" / "biases_2.txt").reshape(-1, 1)
    return net


def clone_from_arrays(params: list[tuple[np.ndarray, np.ndarray]]) -> Network:
    net = new_network()
    for layer, (weights, biases) in zip(net._network, params):
        layer.weights = weights.copy()
        layer.biases = biases.copy()
    return net


def capture_params(net: Network) -> list[tuple[np.ndarray, np.ndarray]]:
    return [(layer.weights.copy(), layer.biases.copy()) for layer in net._network]


def predict_outputs(net: Network, x: np.ndarray) -> np.ndarray:
    return np.array([net.predict(item).reshape(-1) for item in x])


def predict_labels(net: Network, x: np.ndarray) -> np.ndarray:
    return np.argmax(predict_outputs(net, x), axis=1)


def confusion_matrix(y_true: np.ndarray, y_pred: np.ndarray, n_classes: int = 10) -> np.ndarray:
    cm = np.zeros((n_classes, n_classes), dtype=int)
    for actual, predicted in zip(y_true, y_pred):
        cm[int(actual), int(predicted)] += 1
    return cm


def per_class_metrics(cm: np.ndarray) -> list[dict]:
    rows = []
    for digit in range(cm.shape[0]):
        tp = cm[digit, digit]
        fp = cm[:, digit].sum() - tp
        fn = cm[digit, :].sum() - tp
        support = cm[digit, :].sum()
        precision = tp / (tp + fp) if (tp + fp) else 0.0
        recall = tp / (tp + fn) if (tp + fn) else 0.0
        f1 = 2 * precision * recall / (precision + recall) if (precision + recall) else 0.0
        rows.append({
            "digit": digit,
            "support": int(support),
            "precision": round(float(precision), 4),
            "recall": round(float(recall), 4),
            "f1": round(float(f1), 4),
        })
    return rows


def train_with_history(net: Network, x_train: np.ndarray, y_train: np.ndarray) -> list[dict]:
    loss = MSE()
    net._learning_rate = LEARNING_RATE
    history = []
    for epoch in range(1, EPOCHS + 1):
        error = 0.0
        for x, y in zip(x_train, y_train):
            prediction = net.predict(x)
            error += float(loss.loss(y, prediction))
            net.backprop(loss.loss_prime(y, prediction))
        error /= len(x_train)
        if epoch == 1 or epoch % 10 == 0:
            history.append({"epoch": epoch, "mse": round(error, 8)})
    return history


def plot_sample_digits(raw_images: np.ndarray, labels: np.ndarray) -> None:
    fig, axes = plt.subplots(4, 5, figsize=(8.2, 6.2))
    for ax, image, label in zip(axes.ravel(), raw_images[:20], labels[:20]):
        ax.imshow(image.reshape(8, 8), cmap="gray_r", interpolation="nearest")
        ax.set_title(f"{label}")
        ax.set_xticks([])
        ax.set_yticks([])
    fig.suptitle("Representative 8×8 Handwritten Digits", fontsize=15)
    fig.tight_layout()
    fig.savefig(FIG_DIR / "sample_digits.png", dpi=180, bbox_inches="tight")
    plt.close(fig)


def plot_class_counts(labels: np.ndarray) -> None:
    digits, counts = np.unique(labels, return_counts=True)
    fig, ax = plt.subplots(figsize=(8, 4.6))
    ax.bar(digits, counts)
    ax.set_title("Class Balance in the Full Dataset")
    ax.set_xlabel("Digit label")
    ax.set_ylabel("Number of images")
    ax.set_xticks(range(10))
    ax.grid(axis="y", alpha=0.25)
    fig.tight_layout()
    fig.savefig(FIG_DIR / "class_counts.png", dpi=180, bbox_inches="tight")
    plt.close(fig)


def plot_split_counts(labels: np.ndarray, train_idx: np.ndarray, test_idx: np.ndarray) -> None:
    rows = []
    for digit in range(10):
        rows.append({
            "digit": digit,
            "train": int(np.sum(labels[train_idx] == digit)),
            "test": int(np.sum(labels[test_idx] == digit)),
        })
    write_rows(DATA_DIR / "split_class_counts.csv", rows)

    x = np.arange(10)
    width = 0.38
    fig, ax = plt.subplots(figsize=(8.4, 4.8))
    ax.bar(x - width / 2, [row["train"] for row in rows], width, label="train")
    ax.bar(x + width / 2, [row["test"] for row in rows], width, label="test")
    ax.set_title("Stratified 80/20 Split by Digit")
    ax.set_xlabel("Digit label")
    ax.set_ylabel("Number of images")
    ax.set_xticks(range(10))
    ax.legend()
    ax.grid(axis="y", alpha=0.25)
    fig.tight_layout()
    fig.savefig(FIG_DIR / "split_class_counts.png", dpi=180, bbox_inches="tight")
    plt.close(fig)


def plot_average_digits(raw_images: np.ndarray, labels: np.ndarray) -> None:
    fig, axes = plt.subplots(2, 5, figsize=(9, 4.1))
    for digit, ax in enumerate(axes.ravel()):
        avg = raw_images[labels == digit].mean(axis=0).reshape(8, 8)
        ax.imshow(avg, cmap="gray_r", interpolation="nearest")
        ax.set_title(f"mean {digit}")
        ax.set_xticks([])
        ax.set_yticks([])
    fig.suptitle("Average Image by Digit", fontsize=15)
    fig.tight_layout()
    fig.savefig(FIG_DIR / "average_digits.png", dpi=180, bbox_inches="tight")
    plt.close(fig)


def plot_confusion(cm: np.ndarray) -> None:
    fig, ax = plt.subplots(figsize=(7.2, 6.2))
    im = ax.imshow(cm, interpolation="nearest")
    ax.set_title("Innervate Holdout Confusion Matrix")
    ax.set_xlabel("Predicted digit")
    ax.set_ylabel("True digit")
    ax.set_xticks(range(10))
    ax.set_yticks(range(10))
    for i in range(cm.shape[0]):
        for j in range(cm.shape[1]):
            ax.text(j, i, str(cm[i, j]), ha="center", va="center", fontsize=8)
    fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    fig.tight_layout()
    fig.savefig(FIG_DIR / "confusion_matrix.png", dpi=180, bbox_inches="tight")
    plt.close(fig)


def plot_errors(raw_images: np.ndarray, y_true: np.ndarray, y_pred: np.ndarray, test_idx: np.ndarray) -> None:
    mistakes = test_idx[y_true[test_idx] != y_pred]
    mistakes = mistakes[:12]
    if len(mistakes) == 0:
        return
    ncols = min(6, len(mistakes))
    nrows = int(np.ceil(len(mistakes) / ncols))
    fig, axes = plt.subplots(nrows, ncols, figsize=(2.1 * ncols, 2.25 * nrows))
    axes = np.atleast_1d(axes).ravel()
    pred_map = dict(zip(test_idx, y_pred))
    for ax, idx in zip(axes, mistakes):
        ax.imshow(raw_images[idx].reshape(8, 8), cmap="gray_r", interpolation="nearest")
        ax.set_title(f"true {y_true[idx]} → {pred_map[idx]}")
        ax.set_xticks([])
        ax.set_yticks([])
    for ax in axes[len(mistakes):]:
        ax.axis("off")
    fig.suptitle("Examples Misclassified by the From-Scratch Network", fontsize=14)
    fig.tight_layout()
    fig.savefig(FIG_DIR / "holdout_errors.png", dpi=180, bbox_inches="tight")
    plt.close(fig)


def plot_training_curve(history: list[dict]) -> None:
    fig, ax = plt.subplots(figsize=(8, 4.6))
    ax.plot([row["epoch"] for row in history], [row["mse"] for row in history], marker="o")
    ax.set_title("Training Loss for the Innervate Network")
    ax.set_xlabel("Epoch")
    ax.set_ylabel("Mean squared error")
    ax.grid(alpha=0.25)
    fig.tight_layout()
    fig.savefig(FIG_DIR / "training_curve.png", dpi=180, bbox_inches="tight")
    plt.close(fig)


def plot_baselines(rows: list[dict]) -> None:
    fig, ax = plt.subplots(figsize=(8.2, 4.8))
    names = [row["model"] for row in rows]
    acc = [row["holdout_accuracy"] for row in rows]
    ax.barh(names, acc)
    ax.set_title("Holdout Accuracy: Innervate vs. Reference Models")
    ax.set_xlabel("Accuracy on stratified 20% holdout")
    ax.set_xlim(0, 1.02)
    for i, value in enumerate(acc):
        ax.text(value + 0.01, i, f"{value:.1%}", va="center")
    ax.grid(axis="x", alpha=0.25)
    fig.tight_layout()
    fig.savefig(FIG_DIR / "baseline_comparison.png", dpi=180, bbox_inches="tight")
    plt.close(fig)


def plot_margins(outputs: np.ndarray, correct: np.ndarray) -> list[dict]:
    sorted_outputs = np.sort(outputs, axis=1)
    margins = sorted_outputs[:, -1] - sorted_outputs[:, -2]
    rows = []
    for label, mask in [("correct", correct), ("incorrect", ~correct)]:
        vals = margins[mask]
        rows.append({
            "group": label,
            "n": int(vals.size),
            "mean_margin": round(float(np.mean(vals)), 4),
            "median_margin": round(float(np.median(vals)), 4),
            "min_margin": round(float(np.min(vals)), 4),
            "max_margin": round(float(np.max(vals)), 4),
        })
    write_rows(DATA_DIR / "margin_summary.csv", rows)

    fig, ax = plt.subplots(figsize=(7.5, 4.7))
    ax.boxplot([margins[correct], margins[~correct]], tick_labels=["correct", "incorrect"])
    ax.set_title("Prediction Margin by Outcome")
    ax.set_xlabel("Prediction outcome")
    ax.set_ylabel("Top output minus runner-up output")
    ax.grid(axis="y", alpha=0.25)
    fig.tight_layout()
    fig.savefig(FIG_DIR / "prediction_margins.png", dpi=180, bbox_inches="tight")
    plt.close(fig)
    return rows


def quantization_sensitivity(params: list[tuple[np.ndarray, np.ndarray]], x_test: np.ndarray, y_test: np.ndarray) -> list[dict]:
    rows = []
    base = clone_from_arrays(params)
    base_pred = predict_labels(base, x_test)
    rows.append({"fractional_bits": "uncompressed", "accuracy": round(float(np.mean(base_pred == y_test)), 4)})
    for frac_bits in [1, 2, 3, 4, 5, 6, 8]:
        net = clone_from_arrays(params)
        net.compress(3, frac_bits)
        pred = predict_labels(net, x_test)
        rows.append({"fractional_bits": str(frac_bits), "accuracy": round(float(np.mean(pred == y_test)), 4)})
    write_rows(DATA_DIR / "quantization_sensitivity.csv", rows)

    fig, ax = plt.subplots(figsize=(8, 4.6))
    x = list(range(len(rows)))
    ax.plot(x, [row["accuracy"] for row in rows], marker="o")
    ax.set_title("Accuracy After Fixed-Point Compression")
    ax.set_xlabel("Fractional bits in Q3.n compression")
    ax.set_ylabel("Holdout accuracy")
    ax.set_xticks(x)
    ax.set_xticklabels([row["fractional_bits"] for row in rows])
    ax.set_ylim(0, 1.02)
    ax.grid(alpha=0.25)
    fig.tight_layout()
    fig.savefig(FIG_DIR / "quantization_sensitivity.png", dpi=180, bbox_inches="tight")
    plt.close(fig)
    return rows


def save_confusion_csv(cm: np.ndarray) -> None:
    with (DATA_DIR / "confusion_matrix_holdout.csv").open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        writer.writerow(["true\\pred", *range(10)])
        for digit, row in enumerate(cm):
            writer.writerow([digit, *map(int, row)])


def summarize_mistakes(test_idx: np.ndarray, y_test: np.ndarray, pred: np.ndarray, outputs: np.ndarray) -> None:
    sorted_outputs = np.sort(outputs, axis=1)
    margins = sorted_outputs[:, -1] - sorted_outputs[:, -2]
    rows = []
    for local_i, global_i in enumerate(test_idx):
        if y_test[local_i] != pred[local_i]:
            rows.append({
                "dataset_index": int(global_i),
                "true_digit": int(y_test[local_i]),
                "predicted_digit": int(pred[local_i]),
                "prediction_margin": round(float(margins[local_i]), 4),
            })
    write_rows(DATA_DIR / "holdout_mistakes.csv", rows)


def main() -> None:
    with np.load(INNERVATE / "datasets" / "mnist8.npz") as dataset:
        raw_images = dataset["data"].astype("float32")
        labels = dataset["target"].astype(int)

    scaled = raw_images / 15.0
    x_all = scaled.reshape(-1, 64, 1)
    y_all = np.eye(10)[labels].reshape(-1, 10, 1)

    train_idx, test_idx = train_test_split(
        np.arange(len(labels)),
        test_size=TEST_SIZE,
        random_state=RANDOM_STATE,
        stratify=labels,
    )
    train_idx = np.array(train_idx)
    test_idx = np.array(test_idx)

    np.random.seed(RANDOM_STATE)
    net = new_network()
    history = train_with_history(net, x_all[train_idx], y_all[train_idx])
    trained_params = capture_params(net)

    test_outputs = predict_outputs(net, x_all[test_idx])
    test_pred = np.argmax(test_outputs, axis=1)
    train_pred = predict_labels(net, x_all[train_idx])

    train_acc = float(np.mean(train_pred == labels[train_idx]))
    test_acc = float(np.mean(test_pred == labels[test_idx]))
    cm = confusion_matrix(labels[test_idx], test_pred)

    compressed = clone_from_arrays(trained_params)
    compressed.compress(3, 4)
    comp_pred = predict_labels(compressed, x_all[test_idx])
    comp_acc = float(np.mean(comp_pred == labels[test_idx]))

    # Original saved model / original final-50 split, included as an audit of
    # the historical project rather than as the main validation result.
    saved = load_saved_network()
    original_train = np.arange(0, 1747)
    original_test = np.arange(1747, len(labels))
    saved_pred_all = predict_labels(saved, x_all)
    saved_train_acc = float(np.mean(saved_pred_all[original_train] == labels[original_train]))
    saved_test_acc = float(np.mean(saved_pred_all[original_test] == labels[original_test]))

    # Reference models trained on the same 80/20 split. These are not the point
    # of the project; they give a sanity check against ordinary ML tooling.
    baseline_rows = [
        {"model": "Innervate 64→20→10 DNN", "holdout_accuracy": round(test_acc, 4)},
        {"model": "Innervate after Q3.4 compression", "holdout_accuracy": round(comp_acc, 4)},
    ]
    flat_scaled_16 = raw_images / 16.0
    for name, model in [
        ("Logistic regression reference", LogisticRegression(max_iter=3000, random_state=RANDOM_STATE)),
        ("3-nearest-neighbor reference", KNeighborsClassifier(n_neighbors=3)),
    ]:
        model.fit(flat_scaled_16[train_idx], labels[train_idx])
        pred = model.predict(flat_scaled_16[test_idx])
        baseline_rows.append({"model": name, "holdout_accuracy": round(float(accuracy_score(labels[test_idx], pred)), 4)})
    write_rows(DATA_DIR / "baseline_comparison.csv", baseline_rows)

    overall_rows = [
        {"evaluation": "original saved model, original first-1747 training portion", "n": len(original_train), "accuracy": round(saved_train_acc, 4)},
        {"evaluation": "original saved model, original final-50 holdout", "n": len(original_test), "accuracy": round(saved_test_acc, 4)},
        {"evaluation": "retrained Innervate model, stratified 80% training", "n": len(train_idx), "accuracy": round(train_acc, 4)},
        {"evaluation": "retrained Innervate model, stratified 20% holdout", "n": len(test_idx), "accuracy": round(test_acc, 4)},
        {"evaluation": "retrained Innervate model after Q3.4 compression, stratified holdout", "n": len(test_idx), "accuracy": round(comp_acc, 4)},
    ]
    write_rows(DATA_DIR / "overall_metrics.csv", overall_rows)

    split_summary = [
        {"split": "full dataset", "n": len(labels), "accuracy": ""},
        {"split": "stratified training", "n": len(train_idx), "accuracy": round(train_acc, 4)},
        {"split": "stratified holdout", "n": len(test_idx), "accuracy": round(test_acc, 4)},
        {"split": "stratified holdout after Q3.4 compression", "n": len(test_idx), "accuracy": round(comp_acc, 4)},
    ]
    write_rows(DATA_DIR / "split_summary.csv", split_summary)
    write_rows(DATA_DIR / "training_history.csv", history)
    write_rows(DATA_DIR / "per_class_holdout.csv", per_class_metrics(cm))
    save_confusion_csv(cm)
    summarize_mistakes(test_idx, labels[test_idx], test_pred, test_outputs)
    margin_rows = plot_margins(test_outputs, test_pred == labels[test_idx])
    quant_rows = quantization_sensitivity(trained_params, x_all[test_idx], labels[test_idx])

    plot_sample_digits(raw_images, labels)
    plot_class_counts(labels)
    plot_split_counts(labels, train_idx, test_idx)
    plot_average_digits(raw_images, labels)
    plot_confusion(cm)
    plot_errors(raw_images, labels, test_pred, test_idx)
    plot_training_curve(history)
    plot_baselines(baseline_rows)

    print("Innervate analysis regenerated.")
    print(f"Primary split: {len(train_idx)} train / {len(test_idx)} holdout")
    print(f"Innervate holdout accuracy: {test_acc:.3f}")
    print(f"Q3.4 compressed holdout accuracy: {comp_acc:.3f}")
    print(f"Original final-50 holdout accuracy: {saved_test_acc:.3f}")
    print("Baseline rows:")
    for row in baseline_rows:
        print("  ", row)
    print("Margin rows:", margin_rows)
    print("Quantization rows:", quant_rows)


if __name__ == "__main__":
    main()
