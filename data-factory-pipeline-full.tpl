${jsonencode([{
  "name": "Copy",
  "type": "Copy",
  "dependsOn": [],
  "policy": {
    "timeout": "7.00:00:00",
    "retry": 10,
    "retryIntervalInSeconds": 30,
    "secureOutput": false,
    "secureInput": false
  },
  "userProperties": [],
  "typeProperties": {
    "source": {
      "type": "BinarySource",
      "storeSettings": {
        "type": "AzureBlobFSReadSettings",
        "recursive": true,
        "wildcardFolderPath": "*",
        "wildcardFileName": "*",
        "deleteFilesAfterCompletion": false
      }
    },
    "sink": {
      "type": "BinarySink",
      "storeSettings": {
        "type": "AzureBlobFSWriteSettings",
        "copyBehavior": "PreserveHierarchy"
      }
    },
    "enableStaging": false,
    "skipErrorFile": {
        "dataInconsistency": false
    },
    "validateDataConsistency": true
  },
  "inputs": [
    {
      "referenceName": "${sourceDataset}",
      "type": "DatasetReference"
    }
  ],
  "outputs": [
    {
      "referenceName": "${sinkDataset}",
      "type": "DatasetReference",
      "parameters": {
        "OutputPath": {
          "value": "@formatDateTime(pipeline().parameters.ScheduledTriggerTime,'yyyyMM/\\full-backup')",
          "type": "Expression"
        }
      }
    }
  ]
}])}
