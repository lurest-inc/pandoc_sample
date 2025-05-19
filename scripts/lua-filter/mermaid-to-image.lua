local sha1 = pandoc.sha1  -- Pandocが提供するsha1関数を利用

local function run_and_log(command)
  local handle = io.popen(command .. " 2>&1")
  if handle then
    local result = handle:read("*a")
    handle:close()
    io.stderr:write(result .. "\n")
  else
    io.stderr:write("Failed to run command: " .. command .. "\n")
  end
end

local function read_puppeteer_config(path)
  local file = io.open(path, "r")
  if not file then
    io.stderr:write("Error: Could not open " .. path .. "\n")
    return
  end

  local content = file:read("*a")
  file:close()

  -- そのまま出力する（パースまではしない）
  io.stderr:write("=== Puppeteer Config Content ===\n")
  io.stderr:write(content .. "\n")
  io.stderr:write("================================\n")
end

local function run_and_capture(cmd)
  local handle = io.popen(cmd .. " 2>&1")
  if not handle then
    return nil, false
  end
  local output = handle:read("*a")
  local success, exit_type, code = handle:close()
  return output, success, exit_type, code
end

function CodeBlock(el)
  if el.classes:includes("mermaid") then

    local code = el.text
    -- コード内容から一意なハッシュを生成
    local hash = sha1(code)
    local base_filename = "mermaid-" .. hash
    local mmd_filename = "scripts/mermaid/" .. base_filename .. ".mmd"
    local png_filename = "scripts/mermaid/" .. base_filename .. ".png"

    -- 出力先ディレクトリがなければ作成
    os.execute("mkdir -p scripts/mermaid")

    -- .mmdファイルとして書き出す
    local mmd_file = io.open(mmd_filename, "w")
    if not mmd_file then
      io.stderr:write("Error: Could not open file " .. mmd_filename .. "\n")
      return el
    end
    mmd_file:write(code)
    mmd_file:close()

    -- mmdcコマンドでPNGに変換
    local command = string.format(
      "npx mmdc -i %s -o %s --puppeteerConfigFile scripts/mermaid/puppeteer-config.json --configFile scripts/mermaid/mermaid-config.json --theme default",
      mmd_filename, png_filename
    )
    local output, success = run_and_capture(command)
    if not success then
      io.stderr:write("Error: mmdc command failed for " .. mmd_filename .. "\n")
      io.stderr:write("Command output:\n" .. (output or "(no output)") .. "\n")
      return el
    end

    -- 成功したら画像に置き換える
    return pandoc.Para({ pandoc.Image({ pandoc.Str("Mermaid Diagram") }, png_filename) })
  end
  return el
end
