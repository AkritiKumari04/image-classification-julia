module Data

using MLDatasets
using Flux
using Flux: onehotbatch, DataLoader

export get_dataloaders

function get_dataloaders(; batchsize::Int = 32)
    # Load CIFAR-10 with new API
    train = CIFAR10(split = :train)
    test  = CIFAR10(split = :test)

    # Images -> Float32 in [0,1]
    xtrain = Float32.(train.features) ./ 255
    xtest  = Float32.(test.features) ./ 255

    # Labels
    labels_train = vec(train.targets)
    labels_test  = vec(test.targets)
    classes = sort(unique(labels_train))   # 0–9

    # One-hot labels
    ytrain = onehotbatch(labels_train, classes)
    ytest  = onehotbatch(labels_test, classes)

    # Create loaders
    train_loader = DataLoader((xtrain, ytrain); batchsize = batchsize, shuffle = true)
    test_loader  = DataLoader((xtest, ytest);  batchsize = batchsize)

    return train_loader, test_loader
end

end # module
