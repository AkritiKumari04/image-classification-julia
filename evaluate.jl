module Evaluate

using BSON, Flux
using Data, Utils

export evaluate

function evaluate(modelpath="model.bson")

    println("Loading model from: $modelpath")

    # Load model
    d = BSON.load(modelpath)
    m = d[:m]

    # Load test dataset
    _, test_dl = Data.get_dataloaders(batchsize=128)

    accs = Float32[]

    # Evaluate accuracy
    for (x, y) in test_dl
        preds = m(x)
        push!(accs, Utils.accuracy(preds, y))
    end

    println("Test Accuracy: ", mean(accs))

end

end
