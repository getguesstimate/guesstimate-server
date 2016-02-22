## API

# Users

## Get a single user

```bash
  GET /users/:id
```

### Response

```javascript
  {
    "id": 39,
    "name": "ozzieagooen",
    "picture": "https://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg",
    "updated_at": "2016-01-14T23:17:20.048Z",
    "created_at": "2016-01-14T23:17:20.048Z",
    “public_model_count”: 0
    "private_model_count": 0,
    “plan”: {
      “private_model_count”: 20
    },
    "has_private_access": true,
    "account": {
      "has_payment_account": true,
      _links: {
        "payment_portal": {"href": "foobar.com"}
      }
    }
  }
```

# Accounts

## Begin a synchonization of the user account with the subscription manager (Chargebee)
```bash
  GET /users/:id/account/new_subscription_iframe?plan_id=small
```

### Response
```javascript
{
  _links: {
    "new_payment_iframe":  {"href": "foobar.com", "website_name": "google.com"}
  }
}
```


## Begin a synchonization of the user account with the subscription manager (Chargebee)

```bash
  POST /users/:id/account/synchronization
```

### Response

```javascript
  {
    "user_id": 39,
  }
```

## Get a user account

# Spaces

## Get a single space

```bash
  GET /spaces/:id
```

### Response

``` javascript
  {
    "id": 147,
    "name": "United States Population",
    "description": "A very simple model of the population in the US.",
    "created_at": "2016-02-15T01:33:43.139Z",
    "updated_at": "2016-02-15T02:47:49.551Z",
    "graph": {
      "metrics": [
        {
          "id": "279d86c0-d38e-11e5-af52-05ec161cbd04",
          "space": 147,
          "readableId": "XZ",
          "name": "New York Population",
          "location": {
            "row": 1,
            "column": 0
          }
        },
        {
          "id": "4506abb0-d38e-11e5-af52-05ec161cbd04",
          "space": 147,
          "readableId": "QV",
          "name": "Non-New York Population",
          "location": {
            "row": 2,
            "column": 0
          }
        },
        {
          "id": "53782e30-d38e-11e5-af52-05ec161cbd04",
          "space": 147,
          "readableId": "AU",
          "name": "Total",
          "location": {
            "row": 2,
            "column": 1
          }
        }
      ],
      "guesstimates": [
        {
          "metric": "279d86c0-d38e-11e5-af52-05ec161cbd04",
          "input": "[8000000,25000000]",
          "guesstimateType": "NORMAL",
          "description": ""
        },
        {
          "metric": "4506abb0-d38e-11e5-af52-05ec161cbd04",
          "input": "[260000000,340000000]",
          "guesstimateType": "NORMAL",
          "description": ""
        },
        {
          "metric": "53782e30-d38e-11e5-af52-05ec161cbd04",
          "input": "=QV+XZ",
          "guesstimateType": "FUNCTION",
          "description": ""
        }
      ]
    },
    "is_private": false,
    "_embedded": {
      "user": {
        "id": 32,
        "name": "Ozzie Gooen",
        "picture": "https://avatars.githubusercontent.com/u/377065?v=3"
      }
    }
  }
```

## List all spaces for a user

```bash
  GET /users/:user_id/spaces/:id
```

### Response

```javascript
  {
    "items": [
      {
        "id": 146,
        "name": "New York Population",
        "description": "A simple model of the population of New York",
        "created_at": "2016-02-15T01:32:02.680Z",
        "updated_at": "2016-02-15T03:29:38.777Z",
        "is_private": false,
        "user_id": 32
      },
      {
        "id": 147,
        "name": "United States Population",
        "description": "A very simple model of the population in the US.",
        "created_at": "2016-02-15T01:33:43.139Z",
        "updated_at": "2016-02-15T02:47:49.551Z",
        "is_private": false,
        "user_id": 32
      }
    ]
  }
```
