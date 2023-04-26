import os
import cv2
import numpy as np
import matplotlib.pyplot as plt
import tensorflow as tf

# Load the data
mnist = tf.keras.datasets.mnist
(x_train, y_train), (x_test, y_test) = mnist.load_data()

# Normalize the data
x_train = tf.keras.utils.normalize(x_train, axis=1)
x_test = tf.keras.utils.normalize(x_test, axis=1)

# Create the model
model = tf.keras.models.Sequential()

# Add layers to the model
model.add(tf.keras.layers.Conv2D(32, (3,3), activation='relu', input_shape=(28,28,1)))
model.add(tf.keras.layers.MaxPooling2D((2,2)))
model.add(tf.keras.layers.Conv2D(64, (3,3), activation='relu'))
model.add(tf.keras.layers.MaxPooling2D((2,2)))
model.add(tf.keras.layers.Conv2D(64, (3,3), activation='relu'))
model.add(tf.keras.layers.Flatten(input_shape=(28,28)))
model.add(tf.keras.layers.Dense(64, activation='relu'))
model.add(tf.keras.layers.Dense(10, activation='softmax'))

# Compile the model
model.compile(optimizer='adam', loss='sparse_categorical_crossentropy', metrics=['accuracy'])


# Train the model
model.fit(x_train, y_train, epochs=3, validation_data=(x_test, y_test))


# Save the model
model.save('.\Handwritten Digit Recognition\handwritten_digit_recognition.model')


#Once we train and save the model we don't need to train it again and we just load it
savedModel = tf.keras.models.load_model('.\Handwritten Digit Recognition\handwritten_digit_recognition.model')

# Evaluate the model
val_Loss, val_Accuracy = savedModel.evaluate(x_test, y_test)

print(val_Loss) # Want it as much low as possible
print(val_Accuracy)	# Want it as much high as possible



test = 1
digit = 0
while os.path.isfile(f".\Handwritten Digit Recognition\TestDigits\\t{test}d{digit}.png"):
	try:
		img = cv2.imread(f".\Handwritten Digit Recognition\TestDigits\\t{test}d{digit}.png",cv2.IMREAD_GRAYSCALE)
		# We invert it because in paint the background is white and the digit is black and our test data is the opposite
		img = np.invert(np.array([img]))
		prediction = savedModel.predict(img)
		print(f"This number is: {np.argmax(prediction)}")
		plt.imshow(img[0], cmap=plt.cm.binary)
		plt.show()
	except:
		print("Error!")
	finally:
		digit += 1
		if digit>9:
			test += 1
			digit = 0
