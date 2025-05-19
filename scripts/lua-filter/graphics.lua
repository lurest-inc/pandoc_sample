-- Image要素に対して自動的に幅・高さの属性を設定する
function Image(el)
  -- すでにサイズ指定がある場合は変更しない
  if not el.attributes.width and not el.attributes.height then
    el.attributes.width = "\\maxwidth"
    el.attributes.height = "\\maxheight"
    -- keepaspectratioは画像挿入時のオプションとして有効にする
    el.attributes.keepaspectratio = "true"
  end
  return el
end