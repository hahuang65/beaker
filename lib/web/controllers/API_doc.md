# API Documentation
* [Beaker.MetricsApiController](#beakermetricsapicontroller)
  * [counters](#beakermetricsapicontrollercounters)
  * [gauges](#beakermetricsapicontrollergauges)
  * [time_series](#beakermetricsapicontrollertime_series)

## Beaker.MetricsApiController
### Beaker.MetricsApiController.counters
#### GET /api/counters
##### Request
* __Method:__ GET
* __Path:__ /api/counters
* __Request headers:__
```
accepts: application/json
```
* __Request body:__
```json
{
  "aspect": "body_params"
}
```
##### Response
* __Status__: 200
* __Response headers:__
```
content-type: application/json; charset=utf-8
cache-control: max-age=0, private, must-revalidate
```
* __Response body:__
```json
{
  "api": 1
}
```

### Beaker.MetricsApiController.gauges
#### GET /api/gauges
##### Request
* __Method:__ GET
* __Path:__ /api/gauges
* __Request headers:__
```
accepts: application/json
```
* __Request body:__
```json
{
  "aspect": "body_params"
}
```
##### Response
* __Status__: 200
* __Response headers:__
```
content-type: application/json; charset=utf-8
cache-control: max-age=0, private, must-revalidate
```
* __Response body:__
```json
{
  "api_gauge": 100
}
```

### Beaker.MetricsApiController.time_series
#### GET /api/time_series
##### Request
* __Method:__ GET
* __Path:__ /api/time_series
* __Request headers:__
```
accepts: application/json
```
* __Request body:__
```json
{
  "aspect": "body_params"
}
```
##### Response
* __Status__: 200
* __Response headers:__
```
content-type: application/json; charset=utf-8
cache-control: max-age=0, private, must-revalidate
```
* __Response body:__
```json
{
  "api_time_series": [
    {
      "value": 42,
      "time": 1453213013291854
    }
  ]
}
```

