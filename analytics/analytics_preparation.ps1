New-AzureRmStreamAnalyticsJob -Name logs_transfer2 -File job.json -ResourceGroupName minecraft

New-AzureRmStreamAnalyticsTransformation -ResourceGroupName minecraft -JobName logs_transfer2 -Name logs_transfer2 -File transformation.json

New-AzureRmStreamAnalyticsInput -JobName logs_transfer2 -Name logslob -File blob_input.json -ResourceGroupName minecraft