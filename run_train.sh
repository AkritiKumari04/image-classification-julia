julia --project=. -e 'using Pkg; Pkg.instantiate(); using Train; Train.train!(epochs=20, batchsize=128, lr=1e-3, savepath="model.bson")'
