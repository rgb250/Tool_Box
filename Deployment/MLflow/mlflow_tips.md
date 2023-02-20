# Table of contents

## 1) Experiments
### a) Manage experiments
To create an experiment:
````bash
export MLFLOW_EXPERIMENT_NAME=new_experiment
mlflow experiments create --experiment-name new_experiment
mlflow experiments search  # list of existing experiments
````

To rename an experiments 
````bash
exp_id=387198563641749137
mlflow experiments rename -x $exp_id --new-name exp_num_2
````
### b) Start a MLflow session
````bash
mlflow ui
````

## 2) Use MLflow in programming languages

### a) Python
````python
import mlflow
import mlflow.sklearn as msk

model_name = 'regression_mod'
exp_id = mlflow.get_experiment_by_name(args.mlflow_experiment_name).experiment_id
with mlflow.start_run(run_name=name, experiment_id=exp_id):
    mlflow.log_params(params_inputer)
tracking_url_type_store = urlparse(mlflow.get_tracking_uri()).scheme
if tracking_url_type_store != "file":
    msk.log_model(model_pipeline, "model", registered_model_name="Model")
else:
    msk.log_model(model_pipeline, "model")
 


````