# 1. Load library

library(tidyverse) # data wrangling
library(keras) # neural network
library(tensorflow) # neural network
library(reticulate) # translate R to Python

# 2. Set working directory & define size

setwd("/Users/slick/Documents/DATA/archive/images")
label_list <- dir("train/")
output_n <- length(label_list)
save(label_list, file="label_list.R")

width <- 250 # pixel
height <- 250
target_size <- c(width, height)
rgb <- 3 

# 3. Set data generators
path_train <- "train"


train_data_gen <- image_data_generator(rescale = 1/250,
                                       validation_split = 0.2) # fraction image for testing

# 4. Load image data
train_images <- flow_images_from_directory(path_train, 
                                           train_data_gen,
                                           subset = "training",
                                           target_size = target_size, # dimension of image
                                           class_mode = "categorical",
                                           shuffle = FALSE,
                                           classes = label_list, # species of cats
                                           seed = 2023)

validation_images <- flow_images_from_directory(path_train,
                                           train_data_gen,
                                           subset = "validation",
                                           target_size = target_size,
                                           class_mode = "categorical",
                                           shuffle = FALSE,
                                           classes = label_list,
                                           seed = 2023)
## check that train_images are working properly
table(train_images$classes)

plot(as.raster(train_images[[3]][[1]][21,,,]))

# 5. Build the model

## load pre-trained Xception model trained on the IMageNet dataset
model_base <- application_xception(weights = "imagenet",
                                 include_top = FALSE,
                                 input_shape = c(width,height,3))

## freeze weights to prevent weights from being updated
freeze_weights(model_base)

# 6. Define model function

## build a layer on top of the pre-trained network
model_function <- function(learning_rate = 0.001,
                           dropoutrate = 0.2, n_dense = 1024) {
  k_clear_session()
  
  model <- keras_model_sequential() %>%
    model_base %>%
    layer_global_average_pooling_2d() %>%
    layer_dense(units = n_dense) %>%
    layer_activation("relu") %>%
    layer_dropout(dropoutrate) %>%
    layer_dense(units = output_n, activation = "softmax")
  
  model %>% compile (
    loss = "categorical_crossentropy",
    optimizer = optimizer_adam(learning_rate),
    metrics = "accuracy"
  )
  return(model)}

model <- model_function()

batch_size <- 32
epochs <- 6

hist <- model %>%
  fit(train_images,
                steps_per_epoch = train_images$n %/% batch_size,
                epochs = epochs,
                validation_data = validation_images,
                validation_steps = validation_images$n %/% batch_size,
                verbose = 2)


    