local pandoc = require "pandoc"

function CodeBlock(block)
  if block.classes[1] == "dot" then
    local filename = block.identifier .. ".png"
    if filename == ".png" then
      filename = "graph-" .. tostring(os.time()) .. ".png"
    end
    -- Write dot content to a temporary file
    local dotFile = io.open(filename .. ".dot", "w")
    dotFile:write(block.text)
    dotFile:close()
    -- Convert the dot file to an image
    os.execute("dot -Tpng " .. filename .. ".dot -o " .. filename)
    -- Return an image reference
    return pandoc.Para({pandoc.Image({}, filename)})
  end
end