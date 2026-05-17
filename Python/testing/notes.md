- [Pytest](#pytest)
  - [Mock](#mock)

# Pytest

## Mock

````python
@pytest.fixture
def test_args(tmp_path: Path) -> Namespace:
    """
    Creates a Namespace object with test arguments.
    """
    input_file = tmp_path / "sample_input.csv"
    intermediate_path = tmp_path / "intermediate"
    intermediate_path.mkdir(exist_ok=True)
    np.random.seed(42)
    size = 500
    pd.DataFrame(
        {
            "num_col1": np.random.rand(size),
            "num_col2": np.random.randint(1, 100, size),
            "cat_col1": np.random.choice(["A", "B", "C", "D"], size),
            "cat_col2": np.random.choice(["X", "Y", "Z"], size),
            "bool_col": np.random.choice([True, False], size),
        }
    ).to_csv(input_file, index=False)

    args = Namespace(
        input_file_path=input_file.__str__(),
        output_folder_path=tmp_path.__str__(),
        umap_args={"metric": "precomputed", "random_state": 42, "n_components": 2},
        hdbscan_args={"min_cluster_size": 5},
        classifier_args={"iterations": 10, "verbose": 0},
        method="naive",
        method_args={"factor": 5},  # factor * 5 features = 25
        random_state=42,
    )
    return args


def create_test_files(tmp_path: Path, data_size: int, sample_size: int):
    """Helper function to create test files."""
    raw_data = pd.DataFrame({"feature1": np.random.rand(data_size)})
    data_with_strata = pd.DataFrame(
        {
            "feature1": np.random.rand(data_size),
            "stratum": np.random.randint(0, 3, data_size),
        }
    )
    total_sample_size = pd.DataFrame({"total_sample_size": [sample_size]})
    preprocessed_data = pd.DataFrame({"feature1": np.random.rand(data_size)})

    intermediate_path = tmp_path / "intermediate"

    raw_data.to_parquet(intermediate_path / "raw_data.parquet")
    data_with_strata.to_parquet(intermediate_path / "data_with_strata.parquet")
    total_sample_size.to_parquet(intermediate_path / "total_sample_size.parquet")
    preprocessed_data.to_parquet(intermediate_path / "preprocessed_data.parquet")
````

````python
@patch("src.sampling.interface.api.load_config")
@patch("src.sampling.interface.api.DataLoadingAndDescriptiveStats")
def test_run_data_loading(
    mock_dlds: MagicMock, mock_load_config: MagicMock, client: FlaskClient
):
    """
    Test the /run endpoint for data loading.

    This test checks if the /run endpoint correctly initiates the data
    loading step of the pipeline and returns a run ID and features.

    Parameters
    ----------
    mock_dlds : MagicMock
        A mock for the DataLoadingAndDescriptiveStats class.
    mock_load_config : MagicMock
        A mock for the load_config function.
    client : FlaskClient
        A Flask test client.
    """
    # Mock the configuration to avoid dependency on the config file
    mock_load_config.return_value = {"input_file_path": "default.csv"}

    # Mock the DataLoadingAndDescriptiveStats class to isolate the test
    mock_instance = MagicMock()
    mock_instance.get_column_names.return_value = ["col1", "col2", "col3"]
    mock_dlds.return_value = mock_instance

````

````python
def test_get_feature_subset_yes():
    """
    Test the get_feature_subset function with 'yes'.
    """
    with patch("builtins.input", side_effect=["yes", "num_col1, cat_col1"]):
        features = get_feature_subset(["num_col1", "cat_col1", "num_col2"])
        assert features == ["num_col1", "cat_col1"]
````

````python
    mock_dlds_instance = MagicMock()
    mock_dlds_instance.get_column_names.return_value = ["num_col1", "cat_col1"]
    mock_dlds.return_value = mock_dlds_instance
````