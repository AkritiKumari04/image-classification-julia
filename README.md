# 🎯 Image Classification Web App using Julia

A full image-classification web application built using **Julia**, **Flux.jl**, and **CIFAR-10** — with a clean and beautiful web interface.

This project allows users to **upload an image** and get a **predicted label** using a Julia-based server.

---

## 🚀 Features

- 🔥 Custom CNN model using Flux.jl  
- 🌐 Web interface with HTML + CSS  
- 📤 Upload any image for prediction  
- ⚡ Real-time classification  
- 🎨 Beautiful UI  
- 🧠 Supports training your own model  

---

## 🖼 Demo Screenshot  
<img width="1889" height="912" alt="image" src="https://github.com/user-attachments/assets/86871272-7219-4867-a57e-e7c62993e4c6" />

---

## 📂 Project Structure
image-classification-julia/
│── src/
│ ├── model.jl
│ ├── train.jl
│ ├── infer.jl
│ ├── server.jl
│ ├── utils.jl
│── index.html
│── Project.toml
│── Manifest.toml
│── trained_model.bson (optional)



---

## 🏃‍♀️ How to Run
This will start the Julia backend server at http://127.0.0.1:8010.  
Then open index.html in a browser to use the interface.


1.Install Julia packages
```julia
using Pkg
Pkg.instantiate()

2.Start the server
include("src/server.jl")



.

👩‍💻 Author
Akriti Kumari
