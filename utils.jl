module Utils

using Flux, Statistics

function accuracy(preds, labels)
    yhat = mapcols(x -> argmax(x), preds)
    mean(yhat[:] .== labels)
end

end
