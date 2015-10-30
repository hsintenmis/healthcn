/**
* 解釋健康檢測資料，正常或不正常，<BR>
* 顯示說明文字與相關資料
* <P>
*
* 傳入: 健康檢查項目代碼, ex. bmi(參考DB TABLE 'health_member' 欄位)<BR>
* 傳入: 量測數值, 年齡, 性別
* <P>
*
* 回傳: 'stat', ex. 正常, 腰臀比超標 ....<BR>
* 回傳: 'stat_ext', ex. 腰圍95cm, 臀圍:105cm or NULL<BR>
* 回傳: 'explain', 正常數值或是範圍的說明文字, ex. BMI 介於 18.5 ~ 24<BR>
* 回傳: 'result', 正常'good', 不正常'bad', 無數值'none', 可以給'圖片使用'
*
*/

import UIKit
import Foundation

class HealthExplainTestData {
    // Common property
    private var mVCtrl: UIViewController!
    private var pubClass: PubClass!
    
    // USER 資料
    private var usrAge: Int = 30
    private var usrGender: String = "M"
    
    // 全部健康項目的資料
    private var mapAllHealthData: [String: [String:String]] = [:]
    
    /**
    * 檢測數值分析後的 map 文字資料
    * <P>
    * 回傳: 'stat', ex. 正常, 腰臀比超標 ....<BR>
    * 回傳: 'stat_ext', ex. 腰圍95cm, 臀圍:105cm or NULL<BR>
    * 回傳: 'explain', 正常數值或是範圍的說明文字, ex. BMI 介於 18.5 ~ 24<BR>
    * 回傳: 'result', 正常'good', 不正常'bad', 無數值'none', 可以給'圖片使用'
    */
    private var mapResult: [String:String] = [:]
    
    /**
     * Cust init
     */
    func CustInit(mVC: UIViewController) {
        mVCtrl = mVC
        pubClass = PubClass(viewControl: mVCtrl)
    }
    
    /**
    * 設定 user 資料
    */
    func SetUserData(age: Int, gender: String) {
        usrAge = age;
        usrGender = gender;
    }
    
    /**
    * 2015/09/01, 設定全部健康項目的資料
    *
    * @param Map <String, Map<String, String>>
    */
    func SetAllHealthData(map: [String: [String:String]]) {
        mapAllHealthData = map
    }

    
    /**
    * 2015/09/10
    * <P>
    * Hashmap 資料轉換成 JSONObject, 全部的健康檢測資料
    *
    * @return JSONObject
    */
    public JSONObject GetHashMapToJobjAllData(
    Map<String, Map<String, String>> mapData) {
    JSONObject jobjData = new JSONObject();
    
    // loop 健康檢測的項目
    for (String strTestname : mapData.keySet()) {
    JSONObject jobjItem = new JSONObject();
    Map<String, String> mapItem = mapData.get(strTestname);
    
    try {
				for (String key : mapItem.keySet()) {
    jobjItem.put(key, mapItem.get(key));
				}
    
				jobjItem.put("field", strTestname);
    } catch (Exception e) {
    }
    
    if (strTestname.equalsIgnoreCase("whr")) {
    
				// 特殊項目處理 'whr'腰臀比
				String[] arySpecItem = { "waistline", "hipline" };
				try {
    for (String strKey : arySpecItem) {
    Map<String, String> mapSpecItem = mapData.get(strKey);
    JSONObject jobjSubItem = new JSONObject();
    
    for (String key : mapSpecItem.keySet()) {
    jobjSubItem.put(key, mapSpecItem.get(key));
    }
    
    jobjSubItem.put("field", strKey);
    jobjItem.put(strKey, jobjSubItem);
    }
				} catch (Exception e) {
				}
    }
    
    try {
				jobjData.put(strTestname, jobjItem);
    } catch (Exception e) {
    }
    }
    
    return jobjData;
    }
    
    /**
    * 根據檢測項目, 將檢測數值轉換成正確的數字形式<BR>
    * ex. 'height' => '175', weight => '70.5'
    *
    * @param strVal
    *            : 檢測的數值 string
    * @return
    */
    public String GetTestingVal(String strField, String strVal) {
    // 整數型態的 field
    String[] aryIntField = { "height", "calory", "sbp", "dbp", "heartbeat" };
    
    for (String intField : aryIntField) {
    if (strField.equalsIgnoreCase(intField)) {
				try {
    strVal = String.valueOf(Integer.valueOf(strVal));
				} catch (Exception e) {
    strVal = "0";
				}
    
				return strVal;
    }
    }
    
    try {
    Double dbVal = Double.valueOf(strVal);
    strVal = String.format("%.1f", dbVal);
    } catch (Exception e) {
    strVal = "0.0";
    }
    
    return strVal;
    }
    
    /**
    * 2015/09/01,
    * <P>
    * 代入資料為 HashMap, 轉換為 JSONObject <BR>
    * 根據檢測數值(單一個檢測項目)，回傳該健康項目對應結果的 map data
    *
    * @param strTestname
    *            : 檢測項目的 field name
    * @param map
    *            : 項目的 key, val
    * @return
    */
    public Map<String, String> GetTestExplainFromMapData(String strTestname,
    Map<String, String> map) {
    
    JSONObject jobjItem = new JSONObject();
    
    try {
    for (String key : map.keySet()) {
				jobjItem.put(key, map.get(key));
    }
    } catch (Exception e) {
    }
    
    if (!strTestname.equalsIgnoreCase("whr")) {
    return GetTestExplain(strTestname, jobjItem);
    }
    
    // 特殊項目處理 'whr'腰臀比
    String[] arySpecItem = { "waistline", "hipline" };
    try {
    for (String strKey : arySpecItem) {
				Map<String, String> mapItem = mapAllHealthData.get(strKey);
				JSONObject jobjSubItem = new JSONObject();
    
				for (String key : mapItem.keySet()) {
    jobjSubItem.put(key, mapItem.get(key));
				}
    
				jobjItem.put(strKey, jobjSubItem);
    }
    } catch (Exception e) {
    }
    
    return GetTestExplain(strTestname, jobjItem);
    }
    
    /**
    * 根據檢測數值，回傳對應結果的 map data
    *
    * @param strTestname
    * @param JSONObject
    *            : 該項目的 key/val 相關資料, ex. 'val', 'name', 'field' ...
    *            <P>
    *
    * @return : Map<String, String>, ex.<BR>
    *         回傳: 'stat', ex. 正常, 腰臀比超標 ....<BR>
    *         回傳: 'stat_ext', ex. 腰圍95cm, 臀圍:105cm or NULL<BR>
    *         回傳: 'explain', 正常數值或是範圍的說明文字, ex. BMI 介於 18.5 ~ 24<BR>
    *         回傳: 'result', 正常'good', 不正常'bad', 無數值'none', 可以給'圖片使用'
    */
    public Map<String, String> GetTestExplain(String strTestname,
    JSONObject jobjItem) {
    // 初始 mapData
    mapResult = new HashMap<String, String>();
    mapResult.put("stat", null);
    mapResult.put("stat_ext", null);
    mapResult.put("explain", null);
    mapResult.put("result", "none");
    
    // 檢視數值資料是否 == 0 (表示無數據資料)
    boolean isDataNull = true;
    Double doubRs = 0.0;
    try {
    doubRs = Double.valueOf(jobjItem.getString("val"));
    
    if (doubRs > 0.0) {
				isDataNull = false;
    }
    } catch (Exception e) {
    }
    if (isDataNull) {
    return mapResult;
    }
    
    /* 根據 field name, 執行相關數值判斷程序 */
    if (strTestname.equalsIgnoreCase("bmi")) {
    this._setBMI(doubRs);
    } else if (strTestname.equalsIgnoreCase("fat")) {
    this._setFat(doubRs);
    } else if (strTestname.equalsIgnoreCase("water")) {
    this._setWater(doubRs);
    } else if (strTestname.equalsIgnoreCase("calory")) {
    this._setCalory(doubRs);
    }
    // 特殊項目, 腰臀比 whr, 需要其他欄位資料 , waistline, hipline
    else if (strTestname.equalsIgnoreCase("whr")) {
    this._setWhr(jobjItem);
    }
    
    return mapResult;
    }
    
    /**
    * BMI 分析文字, 正常代碼 '002'
    * <P>
    * 說明為字代碼如. bmirs_001, bmival_002
    *
    * @param mapData
    * @return
    */
    private void _setBMI(Double doubRs) {
    String strCode = "001";
    String strRsCode = "bad";
    
    if (doubRs <= 18.5) {
    strCode = "001";
    } else if (doubRs > 18.5 && doubRs <= 24) {
    strCode = "002";
    strRsCode = "good";
    } else if (doubRs > 24 && doubRs <= 27) {
    strCode = "003";
    } else if (doubRs > 27 && doubRs <= 30) {
    strCode = "004";
    } else if (doubRs > 30 && doubRs <= 35) {
    strCode = "005";
    } else {
    strCode = "006";
    }
    
    // 設定分析文字
    mapResult.put("explain", pubClass.getLang("bmival_002"));
    mapResult.put("stat", pubClass.getLang("bmirs_" + strCode));
    mapResult.put("stat_ext", null);
    mapResult.put("result", strRsCode);
    }
    
    private Integer getValInWhichPosition(Double val, Double[] fixVal) {
    for (int i = 0; i < fixVal.length; i++) {
    if (val <= fixVal[i]) {
				return i;
    }
    }
    
    return fixVal.length + 1;
    }
    
    /**
    * 體脂率fat 分析文字, 正常代碼 '002'男, '005'女
    * <P>
    * 代入'性別', 說明為字代碼如. fatrs_001, ...
    *
    * @param mapData
    * @return
    */
    private void _setFat(Double doubRs) {
    BigDecimal b = new BigDecimal(doubRs);
    doubRs = b.setScale(1, BigDecimal.ROUND_HALF_UP).doubleValue();
    
    // 設定年齡性別 對應數值資料 map
    List<Double[]> listFixVal_M = new ArrayList<Double[]>();
    listFixVal_M.add(new Double[] { 12.0, 17.0, 22.0, 99.0 });
    listFixVal_M.add(new Double[] { 12.4, 18.0, 23.0, 99.0 });
    listFixVal_M.add(new Double[] { 13.0, 18.4, 23.0, 99.0 });
    listFixVal_M.add(new Double[] { 13.4, 19.0, 23.4, 99.0 });
    listFixVal_M.add(new Double[] { 14.0, 19.4, 24.0, 99.0 });
    
    List<Double[]> listFixVal_F = new ArrayList<Double[]>();
    listFixVal_F.add(new Double[] { 15.0, 22.0, 26.4, 99.0 });
    listFixVal_F.add(new Double[] { 15.4, 23.0, 27.0, 99.0 });
    listFixVal_F.add(new Double[] { 16.0, 23.4, 27.4, 99.0 });
    listFixVal_F.add(new Double[] { 16.4, 24.0, 28.0, 99.0 });
    listFixVal_F.add(new Double[] { 17.0, 24.4, 28.4, 99.0 });
    
    Map<String, List<Double[]>> mapAllFixData = new HashMap<String, List<Double[]>>();
    mapAllFixData.put("M", listFixVal_M);
    mapAllFixData.put("F", listFixVal_F);
    
    Integer[] aryFixAge = { 17, 30, 40, 60, 120 };
    
    // 比對性別年齡，取得資料所在 poistion
    List<Double[]> listFixVal_curr = mapAllFixData.get(usrGender);
    
    int positionVal = 0, positionAge = 0;
    
    for (int i = 0; i < aryFixAge.length; i++) {
    if (usrAge <= aryFixAge[i]) {
				positionAge = i;
				Double[] fixVal = listFixVal_curr.get(i);
    
				for (int j = 0; j < fixVal.length; j++) {
    if (doubRs <= fixVal[j]) {
    positionVal = j;
    
    break;
    }
				}
				
				break;
    }
    }
    
    // 判定數值是否正常
    String strRsCode = (positionVal == 1) ? "good" : "bad";
    
    // 正常/異常文字, 說明文字(顯示對應的年齡,正常範圍值)
    String strPositionVal = String.format("%03d", positionVal + 1);
    String strPositionAge = String.format("%03d", positionAge + 1);
    
    String strStat = pubClass.getLang("fatrs_" + usrGender + "_"
				+ strPositionVal);
    String strExplain = pubClass.getLang("fatval_" + usrGender + "_"
				+ strPositionAge);
    
    // 設定分析文字
    mapResult.put("explain", strExplain);
    mapResult.put("stat", strStat);
    mapResult.put("stat_ext", null);
    mapResult.put("result", strRsCode);
    }
    
    /**
    * 含水率 water 分析文字, 正常代碼 '002'男, '005'女
    * <P>
    * 代入'年齡', 區間如下：<BR>
    * <=17, 18~30, 31~40, 41~60, >61, 五個區間
    * <P>
    *
    * @param mapData
    * @return
    */
    private void _setWater(Double doubRs) {
    // 設定比對資料 map
    List<Double[]> listFixVal = new ArrayList<Double[]>();
    listFixVal.add(new Double[] { 54.0, 60.0 });
    listFixVal.add(new Double[] { 53.5, 59.5 });
    listFixVal.add(new Double[] { 53.0, 59.0 });
    listFixVal.add(new Double[] { 52.5, 58.5 });
    listFixVal.add(new Double[] { 52.0, 58.0 });
    
    Map<String, Double[]> mapFixVal = new HashMap<String, Double[]>();
    for (int i = 0; i < 5; i++) {
    String code = String.format("%03d", i + 1);
    mapFixVal.put(code, listFixVal.get(i));
    }
    
    // 比較數值資料, 根據年齡取得對應 map 固定比對數值資料
    String strCode = "";
    
    if (usrAge <= 17)
    strCode = "001";
    else if (usrAge >= 18 && usrAge <= 30)
    strCode = "002";
    else if (usrAge >= 31 && usrAge <= 40)
    strCode = "003";
    else if (usrAge >= 41 && usrAge <= 60)
    strCode = "004";
    else
    strCode = "005";
    
    // 判斷數值高/低/正常
    String strRsCode = "normal";
    if (doubRs < mapFixVal.get(strCode)[0])
    strRsCode = "low";
    else if (doubRs > mapFixVal.get(strCode)[1])
    strRsCode = "high";
    
    // 設定分析文字
    mapResult.put("explain", pubClass.getLang("waterval_" + strCode));
    mapResult.put("stat", pubClass.getLang("waterrs_" + strRsCode));
    mapResult.put("stat_ext", null);
    mapResult.put("result", (strRsCode.equalsIgnoreCase("normal") ? "good"
				: "bad"));
    }
    
    /**
    * 基礎代謝 calory 分析文字, 正常代碼 '002'男, '005'女
    * <P>
    * 代入'年齡', 區間如下：<BR>
    * <=8, 9~17, 18~29, 30~49, 50~69, >=70 六個區間
    * <P>
    *
    * @param mapData
    * @return
    */
    private void _setCalory(Double doubRs) {
    int positionVal = 0;
    int normalCalory = 0;  // 該年齡正常的 Calory 值
    int realCalory = doubRs.intValue();
    
    // 年齡範圍 17, 18~29, 30~49, 50~69, 69~120
    Integer[] aryFixAge = { 17, 29, 49, 69, 120 };
    
    // 設定年齡性別 對應數值資料 map
    Map<String, Integer[]> mapCalory = new HashMap<String, Integer[]>();
    mapCalory.put("M", new Integer[] { 1610, 1550, 1500, 1350, 1220 });
    mapCalory.put("F", new Integer[] { 1300, 1210, 1170, 1100, 1010 });
    
    // 比對年齡，取得資料所在 poistion, loop data
    for (int i=0; i<aryFixAge.length; i++) {
    if (usrAge <= aryFixAge[i]) {
				// 取得該年齡正常的 Calory 值
				normalCalory = mapCalory.get(usrGender)[i];
				positionVal = i;
				
				break;
    }
    }
    
    // 判斷數值 正常 / 異常, 測量出的 Calory 應該要 >= 對應年齡的Calory, 表示年輕
    String strRsCode = "bad";
    if (realCalory >= normalCalory)
    strRsCode = "good";
    
    // 正常/異常文字, 說明文字(顯示對應的年齡,正常範圍值)
    String strPositionVal = String.format("%03d", positionVal + 1);
    String strExplain = pubClass.getLang("caloryval_" + usrGender + "_"
				+ strPositionVal);
    
    // 設定分析文字
    mapResult.put("explain", strExplain);
    mapResult.put("stat", pubClass.getLang("caloryrs_" + strRsCode));
    mapResult.put("stat_ext", null);
    mapResult.put("result",strRsCode);
    }
    
    /**
    * 腰臀比 whr 分析文字, 正常代碼 '003'男, '003'女
    * <P>
    *
    * @param jobjItem
    *            : whr 包含: 'waistline', 'hipline' jobj
    *
    * @return
    */
    private void _setWhr(JSONObject jobjItem) {
    // 取得數值文字
    String strWhr = jobjItem.optString("val");
    String strWaist = jobjItem.optJSONObject("waistline").optString("val");
    String strHip = jobjItem.optJSONObject("hipline").optString("val");
    
    // 設定 '腰圍','臀圍' 數值文字
    String strStat_ext = mContext.getString(R.string.healthname_waistline)
				+ ":" + strWaist + mContext.getString(R.string.height_cm)
				+ ", " + mContext.getString(R.string.healthname_hipline) + ":"
				+ strHip + mContext.getString(R.string.height_cm);
    
    // 比較數值，取得結果代碼
    String strCode = "001";
    String strRsCode = "bad";
    
    Double dbRate = Double.valueOf(strWhr);
    Double dbWaist = Double.valueOf(strWaist);
    
    if (usrGender.equalsIgnoreCase("M")) {
    if (dbWaist > 90)
				strCode = (dbRate > 0.9) ? "002" : "001";
    else {
				if (dbRate > 0.9)
    strCode = "004";
				else {
    strCode = "003";
    strRsCode = "good";
				}
    }
    } else {
    if (dbWaist > 80)
				strCode = (dbRate > 0.85) ? "002" : "001";
    else {
				if (dbRate > 0.85)
    strCode = "004";
				else {
    strCode = "003";
    strRsCode = "good";
				}
    }
    }
    
    // 設定分析文字
    mapResult.put("explain", pubClass.getLang("waistval_003"));
    mapResult.put("stat", pubClass.getLang("waistrs_" + strCode));
    mapResult.put("stat_ext", strStat_ext);
    mapResult.put("result", (strRsCode));
    }
    
    /**
    * 健康數值計算，本 method 計算以下數值:<BR>
    * 1. BMI : 體重(公斤) / 身高2(公尺2) 2. 腰臀比 : 腰圍 / 臀圍
    * <P>
    * 計算完成的數值，加入原先代入的 jobjItem 再回傳
    * 
    * @param jobjItem
    *            : ex. {"bmi":"0.0","height":"168.0","weight":"0.0"}
    */
    public JSONObject CalHealthData(String strGroup, JSONObject jobjItem) {
    if (strGroup.equalsIgnoreCase("bmi")) {
    try {
				Double dbWeight = Double.valueOf(jobjItem.optString("weight")) * 10000;
				Double dbHeight = Double.valueOf(jobjItem.optString("height"));
				Double dbBMI = Double.valueOf(dbWeight / (dbHeight * dbHeight));
				jobjItem.put("bmi", String.format("%.1f", dbBMI));
    
    } catch (Exception e) {
				// PubClass.xxLog(e.toString());
    }
    
    return jobjItem;
    }
    
    if (strGroup.equalsIgnoreCase("whr")) {
    try {
				Double dbWhr = Double.valueOf(Double.valueOf(jobjItem
    .optString("waistline"))
    / Double.valueOf(jobjItem.optString("hipline")));
    
				jobjItem.put("whr", String.format("%.2f", dbWhr));
    } catch (Exception e) {
				// PubClass.xxLog(e.toString());
    }
    
    return jobjItem;
    }
    
    return jobjItem;
    }
    
}