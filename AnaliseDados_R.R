title: "Atividade-R"
author: "Luciana Martins"
date: '2022-06-16'


#Pacotes

```{r}
library(tidyverse)
library(rsample)
library(recipes)
library(parsnip)
library(tune)
library(dials)
library(yardstick)
library(readr)
library(tidymodels)
library(skimr)
library(vip)
```

#Sumarizar em tabela

```{r}
home_sales<- readRDS (url("https://gmudatamining.com/data/home_sales.rds"))%>%
  select(-selling_date)

home_split <- initial_split(home_sales,
                            prop = 0.7,
                            strata = selling_price)

```

#Criando dados de Teste e dados de Treino

```{r}
home_training <- home_split %>% 
  training()
home_test <- home_split %>% 
  testing()
```

#Verifica o número de linhas em cada conjunto de dados

```{r}
nrow(home_training)

nrow(home_test)
```

#Principais estatísticas no conjunto de dados de treinamento e teste

```{r}
home_training %>% 
  summarize(min_sell_price = min(selling_price),
            max_sell_price = max(selling_price),
            mean_sell_price = mean(selling_price),
            sd_sell_price = sd(selling_price))

home_test %>% 
  summarize(min_sell_price = min(selling_price),
            max_sell_price = max(selling_price),
            mean_sell_price = mean(selling_price),
            sd_sell_price = sd(selling_price))
```

#Ajustando o modelo de regressão linear

#Especificar um modelo linear

```{r}
linear_model <- linear_reg() %>% 
  set_engine("lm") %>% 
  set_mode("regression")
```

#Treinar o modelo para prever o preço de venda

```{r}
lm_fit <- linear_model %>% 
  fit(selling_price ~ house_age + sqft_living, data = home_training)
```

#Visualizar as informações do modelo

```{r}
lm_fit

tidy(lm_fit)

#prever os resultados e combinar no conjunto de dados de teste
home_predictions <- predict(lm_fit, new_data = home_test)

home_test_results <- home_test %>% 
  select(selling_price, house_age, sqft_living) %>% 
  cbind(home_predictions)

head(home_test_results)

```

#Calcular RMSE e R ao quadrado

```{r}
home_test_results %>% 
  rmse(truth = selling_price, estimate = .pred)
home_test_results %>% 
  rsq(truth = selling_price, estimate = .pred)

```

#Visualização

```{r}
ggplot(home_test_results, aes(x = selling_price, y = .pred)) +
  geom_point(alpha = 0.5) + 
  geom_abline(color = 'blue', linetype = 2) + #representing predicted = actual
  coord_obs_pred() + #standardize the range of both axes
  labs(x = 'Actual Home Selling Price', y = 'Predicted Selling Price')
```

#Melhor do que o ajuste anterior

```{r}
linear_model <- linear_reg() %>% 
  set_engine("lm") %>% 
  set_mode("regression")

linear_fit <- linear_model %>% #fit model with all available indepdendent variables
  last_fit(selling_price ~ ., split = home_split)

predictions_df <- linear_fit %>% 
  collect_predictions()

ggplot(predictions_df, aes(x = selling_price, y = .pred )) +
  geom_point(alpha = 0.5) +
  geom_abline(color = "blue", linetype = 2) +
  coord_obs_pred() +
  labs(x = "actual selling price", y = "predicted selling price")
```
