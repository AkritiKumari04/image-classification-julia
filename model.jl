module Model

using Flux

export build_model

# Convolutional block
function conv_block(in_ch, out_ch)
    Chain(
        Conv((3,3), in_ch => out_ch, pad=1),
        BatchNorm(out_ch),
        relu,
        Conv((3,3), out_ch => out_ch, pad=1),
        BatchNorm(out_ch),
        relu,
        MaxPool((2,2))
    )
end

# Build CNN
function build_model(; num_classes=10)
    Chain(
        conv_block(3, 32),
        conv_block(32, 64),
        conv_block(64, 128),
        x -> reshape(x, :, size(x,4)),  # flatten
        Dense(128*4*4, 256),
        relu,
        Dense(256, num_classes),
        softmax
    )
end

end
