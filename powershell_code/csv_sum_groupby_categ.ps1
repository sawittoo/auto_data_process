# パラメータ設定
$csvPath = "sales_beer_csv.csv"
$groupByColumn = "category"  # グループ化するカラム名
$targetCategories = @("beer1", "beer2")  # 集計対象のカテゴリー
$sumColumns = @("sales_num", "sales")  # 合計を計算するカラム

# CSVファイルの読み込み
$data = Import-Csv -Path $csvPath -Encoding UTF8

# 指定カテゴリーでフィルタリング
$filteredData = $data | Where-Object { $targetCategories -contains $_.$groupByColumn }

# カテゴリー別に集計
$results = $filteredData | Group-Object -Property $groupByColumn | ForEach-Object {
    $categoryName = $_.Name
    $categoryData = $_.Group
    
    # 各カラムの合計を計算
    $sums = @{}
    foreach ($column in $sumColumns) {
        $sums[$column] = ($categoryData | Measure-Object -Property $column -Sum).Sum
    }
    
    # 結果オブジェクトを作成
    $result = [PSCustomObject]@{
        $groupByColumn = $categoryName
    }
    
    foreach ($column in $sumColumns) {
        $result | Add-Member -NotePropertyName $column -NotePropertyValue $sums[$column]
    }
    
    $result
}

# 結果を表示
$results | Format-Table -AutoSize

# 結果をCSVで出力する場合
# $results | Export-Csv -Path "summary_result.csv" -NoTypeInformation -Encoding UTF8