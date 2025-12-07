module Infer

using BSON, Images, ImageTransformations, Flux

export predict_image, predict_label

# Preprocess image: resize to 32x32, reorder HWC -> CHW
function preprocess_image(img_path)
    img = load(img_path) |> Array
    img = Float32.(img) ./ 255
    img = imresize(img, (32,32))
    x = permutedims(img, (3,1,2))
    reshape(x, size(x,1), size(x,2), size(x,3), 1)
end

# Predict class index
function predict_image(modelpath, img_path)
    d = BSON.load(modelpath)
    m = d[:m]
    x = preprocess_image(img_path)
    yhat = m(x)
    argmax(yhat[:,1])   # returns number 1–10
end
# Map CIFAR-10 class index (1–10) to label name
const CIFAR10_LABELS = [
    "airplane", "automobile", "bird", "cat", "deer",
    "dog", "frog", "horse", "ship", "truck"
]

function predict_label(modelpath, img_path)
    idx = predict_image(modelpath, img_path)  # number 1–10
    return CIFAR10_LABELS[idx]
end


end
