function Table(tbl)
  if type(tbl) == "table" then
    tbl.width = "100%"
    if tbl.columns then
      for i, col in ipairs(tbl.columns) do
      end
    end
  end
  return tbl
end