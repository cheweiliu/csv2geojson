# 地藉資料Geojson轉換器

## 安裝

```
gem install bundler
bundle install
```

## 使用

地藉資料csv必有欄位：

縣市、段、地號，小段可選。

請下載csv檔案後，於資料夾內執行：

```
./csv2geojson.rb ${csv檔案}
```

結果會放置於 `output/output.geojson` 。

## 授權條款

MIT


