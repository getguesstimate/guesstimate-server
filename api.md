There is a small public API for organizational use. To use it, you first need an API token. Right now you can get this by emailing us, or if you are self hosting, running `organization.enable_api_access!`.

The current (in-alpha) API allows for the following commands. Set the headers:

```json
{
  "API_TOKEN": "#{api_token}",
  "Content-Type": "application/json"
}
```

## Endpoints

`GET https://api.getguesstimate.com/organizations/{#organization_id}/facts`: Lists all facts by an organization  
`POST https://api.getguesstimate.com/organizations/{#organization_id}/facts`: Creates a fact  
`DELETE https://api.getguesstimate.com/organizations/{#organization_id}/facts/#{fact_id}`: Deletes a fact  
`PATCH https://api.getguesstimate.com/organizations/{#organization_id}/facts/#{fact_id}`: Edits a fact

## Example fact response

```json
{
  "id": 247,
  "organization_id": 1,
  "name": "Population of hometown",
  "expression": "3333",
  "variable_name": "population_of_hometown",
  "simulation": {
    "sample": {
      "values": [3333]
    },
    "stats": {
      "length": 1,
      "mean": 3333,
      "stdev": 0
    }
  },
  "created_at": "2016-12-17T05:39:14.987Z",
  "updated_at": "2016-12-17T05:39:14.987Z"
}
```

Of these parameters, "name", "expression", "variable_name", and "simulation" are editable.

**name**: The publically viewable name for the metric.

**variable_name**: The reference name for the variable, used in other functions. This is not hard coded in those functions; so changing this later on will not break them (internally they will reference the fact ID).

**expression**: This is what a user enters as the value for the metric. If it is an exact number, you can specify that directly; if it is an array, use commas ("3,4,5,6,7,8").

**simulation**: This is a bunch of derived data from the expression, typically simulated in the javascript client. If you are to POST or PATCH data, make sure to get at least the 'values' and 'length' right, as it is not done for you.
