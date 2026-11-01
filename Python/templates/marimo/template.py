import marimo

__generated_with = "0.25.0"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo

    return (mo,)


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    # Library loading
    """)
    return


@app.cell
def _():
    import numpy as np
    import pandas as pd
    from pathlib import Path
    import logging
    import colorlog
    LOG_COLORS = {
        "DEBUG": "cyan",
        "INFO": "green",
        "WARNING": "yellow",
        "ERROR": "red",
        "CRITICAL": "red,bg_white",
    }

    logging.basicConfig(
        level=logging.DEBUG,
        format="%(asctime)s - %(name)s - %(funcName)s - %(levelname)s - %(message)s",
        handlers=[
            logging.FileHandler("debug.log", mode="w", encoding="utf-8"),
            logging.StreamHandler(),
        ],
    )

    # Replace the StreamHandler's formatter with ColoredFormatter
    logging.getLogger().handlers[1].setFormatter(
        colorlog.ColoredFormatter(
            "%(asctime)s - %(name)s - %(funcName)s - %(log_color)s%(levelname)s%(reset)s - %(message)s",
            log_colors=LOG_COLORS,
        )
    )

    # Set the console handler to a higher level to reduce verbosity
    logging.getLogger().handlers[1].setLevel(logging.INFO)
    logger = logging.getLogger(__name__)
    return (Path,)


@app.cell(hide_code=True)
def _(mo):
    mo.md(r"""
    # Data Loading
    """)
    return


@app.cell
def _(Path):
    path_folder_input = Path(r"")
    path_folder_input.is_dir(), f'"{path_folder_input}" not found!'
    return


if __name__ == "__main__":
    app.run()
