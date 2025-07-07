# Projeto - Carrinho de compras
O projeto desafio consiste em uma API para gerenciamento do um carrinho de compras de e-commerce.

## Informações técnicas

### Dependências
- ruby 3.3.1
- rails 7.1.3.2
- postgres 16
- redis 7.0.15

## Como executar o projeto

### Executando a app com o docker
Dado que ja tenha o projeto clonado:

Gere a imagem e suba os containers:
```bash
docker compose up
```

Acesse o container:
```bash
docker exec -it rdstation-app bash
```

Estando dentro do container, é possivel executar comandos da mesma forma:

Executar os seeds:
```bash
bundle exec rails db:seeds
```

Executar console em modo sandbox:
```bash
bundle exec rails console --sandbox
```

Executar os testes:
```bash
bundle exec rspec
```

### Executando a app sem o docker
Dado que todas as as ferramentas estão instaladas e configuradas:

Instalar as dependências do:
```bash
bundle install
```

Executar o sidekiq:
```bash
bundle exec sidekiq
```

Executar projeto:
```bash
bundle exec rails server
```

Executar os testes:
```bash
bundle exec rspec
```

## ENDPOINTS

### 1. Registrar um produto no carrinho
Realiza inserção de produtos no carrinho, caso não exista um carrinho para a sessão, cria o carrinho e salva o ID do carrinho na sessão.

ROTA: `/cart`
Payload:
```js
{
  "product_id": 345, // id do produto sendo adicionado
  "quantity": 2, // quantidade de produto a ser adicionado
}
```

### Sucesso
Resposta
```js
{
  "id": 789, // id do carrinho
  "products": [
    {
      "id": 345,
      "name": "Nome do produto",
      "quantity": 2,
      "unit_price": 1.99, // valor unitário do produto
      "total_price": 3.98, // valor total do produto
    }
  ],
  "total_price": 3.98 // valor total no carrinho
}
```

### Falhas
Resposta em caso de produto ja estar no carrinho
```js
{
  "errors": ["Product already exists in cart"]
}
```

Resposta em caso de payload com quantidade negativa
```js
{
  "errors": ["Quantity must be greater than 0"]
}
```

Resposta em caso de payload com quantidade 0
```js
{
  "errors": ["Quantity must be greater than 0"]
}
```

Resposta em caso de payload com produto que não existe
```js
{
  "errors": ["Product must exist"]
}
```

Resposta em caso de não houver sessao
```js
{
  "errors": "Session not found, please create a new cart"
}
```


### 2. Listar itens do carrinho atual
Realiza a listagem dos produtos no carrinho atual.

ROTA: `/cart`
### Sucesso
Resposta:
```js
{
  "id": 789, // id do carrinho
  "products": [
    {
      "id": 645,
      "name": "Nome do produto",
      "quantity": 2,
      "unit_price": 1.99, // valor unitário do produto
      "total_price": 3.98, // valor total do produto
    },
    {
      "id": 646,
      "name": "Nome do produto 2",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98,
    },
  ],
  "total_price": 7.96 // valor total no carrinho
}
```

### Falhas
Resposta em caso de não houver sessao
```js
{
  "errors": "Session not found, please create a new cart"
}
```


### 3. Alterar a quantidade de produtos no carrinho 
Um carrinho pode ter _N_ produtos, se o produto já existir no carrinho, altera a informacao de quantidade.

ROTA: `/cart/add_item`
Payload
```json
{
  "product_id": 1230,
  "quantity": 1
}
```

### Sucesso
Resposta:
```json
{
  "id": 1,
  "products": [
    {
      "id": 1230,
      "name": "Nome do produto X",
      "quantity": 2, // considerando que esse produto já estava no carrinho
      "unit_price": 7.00, 
      "total_price": 14.00, 
    },
    {
      "id": 1020,
      "name": "Nome do produto Y",
      "quantity": 1,
      "unit_price": 9.90, 
      "total_price": 9.90, 
    },
  ],
  "total_price": 23.9
}
```

### Falhas
Resposta em caso de payload product_id que nao existe no carrinho
```json
{
  "errors": "The product does not exist in the cart"
}
```

Resposta em caso de payload product_id nao existe
```json
{
  "errors": "Couldn't find Product with 'id'=999999"
}
```

Resposta em caso de não houver sessao
```js
{
  "errors": "Session not found, please create a new cart"
}
```

### 4. Remover um produto do carrinho 

Exclui um produto do carrinho. 

ROTA: `/cart/:product_id`
### Sucesso
Resposta:
```json
{
  "id": 1,
  "products": [],
  "total_price": 0.0
}
```

### Falhas
Resposta em caso de payload product_id que nao existe no carrinho
```json
{
  "errors": "The product does not exist in the cart"
}
```

Resposta em caso de payload product_id nao existe
```json
{
  "errors": "Couldn't find Product with 'id'=999999"
}
```

Resposta em caso de não houver sessao
```js
{
  "errors": "Session not found, please create a new cart"
}
```
