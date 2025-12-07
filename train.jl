module Train

using Flux
using Flux: onecold
using Flux.Optimisers: Adam
using BSON: @save
using Statistics
using Random
using Main.Data

export train!

# Simple convnet for CIFAR10 (input 32x32x3)
function build_model(num_classes::Int = 10)
    return Chain(
        Conv((3, 3), 3 => 16, relu; pad = 1),
        MaxPool((2, 2)),
        Conv((3, 3), 16 => 32, relu; pad = 1),
        MaxPool((2, 2)),
        Conv((3, 3), 32 => 64, relu; pad = 1),
        x -> reshape(x, :, size(x, 4)),   # flatten (features, batch)
        Dense(64 * 8 * 8, 128, relu),     # 32x32 -> 16x16 -> 8x8 after 2 pools
        Dense(128, num_classes),
        softmax
    )
end

# compute accuracy on batches (onehot targets)
function accuracy(model, batches)
    total = 0
    correct = 0
    for (x, yoh) in batches
        preds = model(x)
        pclasses = onecold(preds, 1:size(yoh, 1))
        tclasses = onecold(yoh, 1:size(yoh, 1))
        correct += sum(pclasses .== tclasses)
        total += length(tclasses)
    end
    return correct / total
end

"""
    train!(; epochs=2, batchsize=32, lr=1e-3, savepath="model.bson")

Train the CIFAR-10 model and save it.
"""
function train!(; epochs::Int = 2,
                 batchsize::Int = 32,
                 lr::Float64 = 1e-3,
                 savepath::String = "model.bson")

    println("Loading data...")
    train_batches, test_batches = Data.get_dataloaders(batchsize = batchsize)

    println("Building model...")
    model = build_model(10)

    # loss as a function of model, inputs and labels
    loss_fn(m, x, y) = Flux.crossentropy(m(x), y)

    # NEW optimiser API: set up state from optimiser + model
    opt_state = Flux.setup(Adam(lr), model)

    # optional reproducibility
    Random.seed!(1234)

    println("Starting training for $epochs epochs...")
    for epoch in 1:epochs
        epoch_loss = 0.0
        nb = 0

        for (x, y) in train_batches
            # gradient of loss w.r.t. the model only
            gs = gradient(m -> loss_fn(m, x, y), model)

            # gs is a 1-element tuple; first element is the model gradient
            Flux.update!(opt_state, model, gs[1])

            # track loss for logging
            l = loss_fn(model, x, y)
            epoch_loss += l
            nb += 1
        end

        train_acc = accuracy(model, train_batches)
        test_acc  = accuracy(model, test_batches)
        println("Epoch $epoch | avg_loss=$(epoch_loss/nb) | " *
                "train_acc=$(round(train_acc*100, digits=2))% | " *
                "test_acc=$(round(test_acc*100, digits=2))%")
    end

    println("Saving model to $savepath ...")
    @save "$savepath" model
    println("Done.")
end

end # module
