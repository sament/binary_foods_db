# BinaryFoodsDb

To search food by ingredients

On local machine simply run iex -S mix or mix

URLS

 GET  http://localhost:4000/meals
  or /meal_id to return specific meal

  GET http://localhost:4000/ingredients
   or /ingredient_id to return specific ingredient

 POST http://localhost:4000/search
    params: JSON ingredients["tomatoes", rice"] returns all meals composed of tomatoes and rice
