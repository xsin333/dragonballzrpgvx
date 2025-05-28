#==============================================================================
# ■ Window_SaveFile
#------------------------------------------------------------------------------
# 　セーブ画面およびロード画面で表示する、セーブファイルのウィンドウです。
#==============================================================================

class Window_SaveFile < Window_Base
  include Share
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :filename                 # ファイル名
  attr_reader   :file_exist               # ファイル存在フラグ
  attr_reader   :time_stamp               # タイムスタンプ
  attr_reader   :selected                 # 選択状態
  attr_reader   :game_switches                 #
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     file_index : セーブファイルのインデックス (0～3)
  #     filename   : ファイル名
  #--------------------------------------------------------------------------
  def initialize(file_index, filename)
    super(0, 56 + file_index % 4 * 90, 640, 90)
    @file_index = file_index
    @filename = filename
    load_gamedata
    refresh
    @selected = false
  end
  #--------------------------------------------------------------------------
  # ● ゲームデータの一部をロード
  #    スイッチや変数はデフォルトでは未使用 (地名表示などの拡張用) 。
  #--------------------------------------------------------------------------
  def load_gamedata
    @time_stamp = Time.at(0)
    @file_exist = FileTest.exist?(@filename)
    if @file_exist
      file = File.open(@filename, "r")
      @time_stamp = file.mtime
      load_laps = false
      begin
        @characters     = Marshal.load(file)
        @frame_count    = Marshal.load(file)
        @last_bgm       = Marshal.load(file)
        @last_bgs       = Marshal.load(file)
        @game_system    = Marshal.load(file)
        @game_message   = Marshal.load(file)
        @game_switches  = Marshal.load(file)
        @game_variables = Marshal.load(file)
        game_self_switches  = Marshal.load(file)
        game_actors         = Marshal.load(file)
        game_party          = Marshal.load(file)
        game_troop          = Marshal.load(file)
        game_map            = Marshal.load(file)
        game_player         = Marshal.load(file)
        carda               = Marshal.load(file) #味方カード攻撃
        cardg               = Marshal.load(file) #味方カード防御
        cardi               = Marshal.load(file) #味方カード流派
        cardi_max           = Marshal.load(file) #流派種類最大数
        @partyc              = Marshal.load(file)
        
        
        #高速化中も正しい時間が表示されるようにする
        #対策を入れても高速化中は時間が半分になってしまうので処理を入れる
        if Graphics.frame_rate == 60
          @total_sec = @frame_count / Graphics.frame_rate
        else
          @total_sec = @frame_count / Graphics.frame_rate * 2
        end
        
        for x in 1..21 #大猿状態表示ここをONにするとファイルが読み込めなくなるので一旦OFFに
          tmp = Marshal.load(file)
        end
        @oozaru_flag        = Marshal.load(file)
        load_laps = true
        for x in 1..22 #クリア回数読み込み用
          tmp = Marshal.load(file)
        end
        @game_laps        = Marshal.load(file) #クリア回数
        load_laps = false
      rescue
        #周回数表示でエラーなのであれば、それは読み込みOKとする
        if load_laps == false
          @file_exist = false
        end
      ensure
        #シナリオ進行度によってファイル名の頭文字を変える
        chk_scenario_progress @game_variables[40]
        #p $top_file_name
        file.close
      end

    end
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    
    self.contents.clear
    self.contents.font.color = normal_color
    #name = Vocab::File + " #{@file_index + 1}"
    name = Vocab::File + "#{@file_index + 1}"
    self.contents.font.color.set( 0, 0, 0)
    self.contents.font.shadow = false
    self.contents.font.bold = true
    if @file_exist
      #chk_scenario_progress
      draw_party_characters(152, 58)
      draw_laps
      #draw_playtime(0, 34, contents.width - 4, 2)
      draw_playtime(2, 0, contents.width - 4, 2)
      draw_story_so_far(98, 0, 300, 0)
    end
    self.contents.draw_text(18, 0, 400, WLH, name)
    @name_width = contents.text_size(name).width
    
  end
  #--------------------------------------------------------------------------
  # ● パーティキャラの描画
  #     x : 描画先 X 座標
  #     y : 描画先 Y 座標
  #--------------------------------------------------------------------------
  def draw_party_characters(x, y)
    for i in 0...@partyc.size
      #name = @characters[i][0]
      #index = @characters[i][1]
      output_character i,x,y
    end
  end
  #--------------------------------------------------------------------------
  # ● タイトルの描画
  #     x     : 描画先 X 座標
  #     y     : 描画先 Y 座標
  #     width : 幅
  #     align : 配置
  #--------------------------------------------------------------------------
  def draw_story_so_far(x, y, width, align)
    
    story_string = "『"
    case @game_variables[43]
    when 0 #ドラゴンレーダー取得後
      story_string += "迫近的恐怖!! 赛亚人来袭!!"
    when 1 #ドラゴンレーダー取得後
      story_string += "地球最强大的力量去营救悟饭!!"
    when 2 #蛇の道
      story_string += "目标是界王星!! 悟空从蛇道出发!!!"
    when 3 #サンショエリア
      story_string += "Ｚ战士、向北出发!!!"
    when 4 #バブルス修行
      story_string += "秘密的特训开始!!!"
    when 5 #ニッキーエリア
      story_string += "Ｚ战士、目标是东方!!"
    when 6 #グレゴリー修行
      story_string += "第二阶段★击败古雷格利!!"
    when 7 #ジンジャーエリア
      story_string += "在大沙漠中寻找龙珠!!!"
    when 8 #ガーリックエリア
      story_string += "决战! 卡里克城!!"
    when 9 #ガーリックエリア(３人衆撃破後)
      story_string += "Ｚ战士、死守地球!!!"
    when 10 #界王様修行
      story_string += "你能掌握界王拳吗!!?"
    when 11 #ベジータエリア
      story_string += "Ｚ戦士们! 在决战之地集结!!!"
    when 12 #ベジータエリア(サイバイマン撃破後)
      story_string += "击败那巴!!!"
    when 13 #ベジータエリア(ナッパ撃破後)
      story_string += "最终决战!! 贝吉塔!!!"
    when 16 #この世で一番強いやつ(氷原エリア)
      story_string += "向神秘的鹤舞山进发!!"
    when 17 #この世で一番強いやつ(要塞エリア)
      story_string += "救出龟仙人和布尔玛!!"
    when 18 #この世で一番強いやつ(バイオ戦士撃破後エリア)
      story_string += "这个世界上最强的人"
    when 21 #宇宙
      story_string += "目标! 龙珠的故乡那美克星!!"
    when 22 #ナメック星
      story_string += "坏蛋们集中在那美克星上!? 都在找龙珠!!"
    when 23 #宇宙
      story_string += "悟空出击!! 迈向新的战斗!!!"
    when 24 #ナメック星2
      story_string += "收集龙珠!"
    when 25 #宇宙
      story_string += "加油悟空!! 战斗力再飞跃!!!"
    when 26 #ナメック星2
      story_string += "收集龙珠!"
    when 27 #宇宙
      story_string += "悟空超重力修炼完成了!"
    when 28 #ピッコロ修行
      story_string += "比克！见识下魔族的力量吧!!!"
    when 29 #ナメック星2
      story_string += "赶紧去找大长老!!!"
    when 30 #ナメック星3
      story_string += "基纽特战队前来拜见!!"
    when 31 #ナメック星4
      story_string += "Ｚ战士对战基纽特战队!!"
    when 32 #ナメック星4
      story_string += "龙珠危机!! 丹迪! 赶紧呀!!!"
    when 33 #ナメック星4
      story_string += "命运的瞬间! 波仑加出現!!"
    when 34 #ナメック星4
      story_string += "超级那美克星人比克诞生!!!"
    when 35 #ナメック星4
      story_string += "充满威胁的弗利萨第２变身!!!"
    when 36 #ナメック星4
      story_string += "Ｚ战士对战完全形态弗利萨!!!"
    when 41 #バーダック編
      story_string += "只有一个人的最终决战"
    when 51 #Z3地球
      story_string += "收集龙珠!!"
    when 52 #Z3ベジータ
      story_string += "贝吉塔登场場!!"
    when 53 #Z3ベジータ
      story_string += "悟空回归"
    when 54 #Z3ベジータ
      story_string += "贝吉塔出击!!"
    when 55 #Z3ベジータ
      story_string += "救出布尔玛!"
    when 56 #Z3ベジータ
      story_string += "修炼"
    when 57 #Z3クウラ
      story_string += "古拉到达!!"
    when 58 #Z3人造人間20、19撃破前
      story_string += "人造人…"
    when 59 #Z3人造人間20、19撃破後
      story_string += "前往研究所…"
    when 60 #Z3人造人間16～18号復活後
      story_string += "１７号、１８号 还有… １６号"
    when 61 #Z3人造人間16～18号戦闘後
      story_string += "邪恶的预感"
    when 65 #Z3魔凶星編東(ガッシュ)
      story_string += "Ｚ战士、向东进发!!"
    when 66 #Z3魔凶星編西(ビネガー)
      story_string += "Ｚ战士、向西进发!!"
    when 67 #Z3魔凶星編南(タード)
      story_string += "Ｚ战士、向南进发!!"
    when 68 #Z3魔凶星編北(タード)
      story_string += "比克和贝吉塔! 向北进发!!"
    when 69 #Z3魔凶星編東(ガーリック)
      story_string += "天界怎么了!? 紧急!Ｚ战士!!"
    when 81 #Z4Dr.ゲロ地下研究所破壊
      story_string += "沙鲁诞生的秘密! 研究所的地下究竟有什么!?"
    when 82 #Z4ベジータとトランクス精神と時の部屋
      story_string += "在精神时光屋…"
    when 83 #Z4天津飯たちセルのもとへ向かう
      story_string += "悄悄的出现！沙鲁!"
    when 84 #Z416号
      story_string += "沉默的战士16号站出来了!!"
    when 85 #Z4ベジータとトランクスセルのもとへ
      story_string += "新生的贝吉塔父子出击!!"
    when 86 #Z4未使用
      story_string += "孙悟空和孙悟饭"
    when 87 #Z4未使用
      story_string += "名叫沙鲁的破坏神诞生!!"
    when 88 #Z4未使用
      story_string += "沙鲁的突发奇想"
    when 89 #Z悟空と悟飯精神と時の部屋
      story_string += "悟空和悟饭… 比克亲子的最终练级"
    when 90 #Z4メタルクウラ編(ナメック星)
      story_string += "拯救新那美克星的危机!!"
    when 91 #Z4メタルクウラ編(ビッグゲテスター)
      story_string += "激战!!100亿战斗力的战士们"
    when 92 #Z4人造人間編
      story_string += "Ｚ战士对战迷一般的人造人!!"
    when 93 #Z4人造人間編
      story_string += "极限战斗!!三大超级赛亚人"
    when 94 #Z4地球人精神と時の部屋(13号編の前なので注意)
      story_string += "地球人啊 追上赛亚人！！"
    when 95 #Zセルゲーム(サタン戦闘前)
      story_string += "沙鲁游戏开幕!"
    when 96 #Zセルゲーム(サタン戦闘後)
      story_string += "超级战斗!沙鲁游戏!!"
    when 97 #セルゲーム戦闘用(入れ替えの調整のため使用)
      
    when 101 #バーダック編(ラディッツ)
      story_string += "巴达克! 救救你的孙子悟饭!!"
    when 111 #未来悟飯編
      story_string += "对绝望的反抗!! 残存的超级战士"
    when 121 #ブロリー編
      story_string += "燃烧!! 热战 烈战 超级战"
    when 126 #ボージャック編(前半)
      story_string += "神秘的银河战士!!"
    when 127 #ボージャック編(後半)
      story_string += "银河的边缘！！绝顶厉害的家伙"
    when 128 #ボージャック編予備2
      story_string += "ボージャック予備2"
    when 131 #エピソードオブバーダック
      story_string += "エピソードオブバーダック"
    when 143 #ZGバーダック一味編(宇宙)
      story_string += "巴达克的同伴在悲伤之后…"
    when 144 #ZGバーダック一味編(ターレス)
      story_string += "背叛弗利萨的人"
    when 145 #ZGバーダック一味編(スラッグ)
      story_string += "多玛他们的困惑"
    when 146 #ZGバーダック一味編(フリーザ)
      story_string += "弗利萨的谋划…"
    when 147 #ZGバーダック一味編(スラッグ)
      story_string += "バーダック一味予備"
    when 148 #ZGバーダック一味編(スラッグ)
      story_string += "バーダック一味予備"
    when 149 #ZGバーダック一味編(スラッグ)
      story_string += "バーダック一味予備"
    when 151 #ZGグランドアポロン
      story_string += "悟空和巴达克前往阿波罗大峡谷"
    when 156 #ZG西の砂漠
      story_string += "悟饭他们朝西部沙漠而去"
    when 161 #ZGブンブク島
      story_string += "比克他们前往布恩布克岛"
    when 166 #ZG氷の大陸
      story_string += "冰之大陆、那里会发生什么呢！？"
    when 171 #ZG西の都(トンガリタワーへ)
      story_string += "最后的毁灭之气发生装置…"
    when 173 #ZGブンブク島(リキニュウム)
      story_string += "在布恩布克岛寻找紫晶石"
    when 175 #ZGクーン星
      story_string += "破除魔咒的护身符在哪里"
    when 181 #ZGオウター星
      story_string += "跟踪海盗船、前往奥托星球！"
    when 186 #ZG暗黒惑星
      story_string += "最终决战、黑暗行星！！"
    when 801 #時の間 外伝クリア後のパイクーハン、ブウ、アラレ戦の時よう(戦闘が終わったら元に戻す)
    when 901 #時の間:ラディッツエリア
      story_string += "时之间：拉蒂兹区域"  
    when 902 #時の間:ガーリックエリア
      story_string += "时之间：卡里克区域"
    when 903 #時の間:界王エリア
      story_string += "时之间：界王区域"
    when 904 #時の間:ベジータエリア
      story_string += "时之间：贝吉塔区域" 
    when 905 #時の間:ウィローエリア
      story_string += "时之间：威洛博士区域" 
    when 911 #時の間:キュイエリア
      story_string += "时之间：邱夷区域"
    when 912 #時の間:ドドリアエリア
      story_string += "时之间：多多利亚区域" 
    when 913 #時の間:ザーボンエリア
      story_string += "时之间：萨博区域" 
    when 914 #時の間:ギニューエリア
      story_string += "时之间：基纽区域" 
    when 915 #時の間:フリーザエリア
      story_string += "时之间：弗利萨区域" 
    when 921 #時の間:クラズエリア
      story_string += "时之间：克拉斯区域" 
    when 922 #時の間:ピラールエリア
      story_string += "时之间：皮拉尔区域" 
    when 923 #時の間:カイズエリア
      story_string += "时之间：凯泽区域" 
    when 924 #時の間:クウラエリア
      story_string += "时之间：古拉区域" 
    when 925 #時の間:人造人間エリア
      story_string += "时之间：人造人区域"
    when 926 #時の間:人造人間エリア
      story_string += "时之间：卡里克区域(魔凶星)" 
    when 931 #時の間:Z4ウィローエリア
      story_string += "时之间：威洛博士区域(盖洛博士研究所)"
    when 932 #時の間:セル第一形態エリア
      story_string += "时之间：沙鲁区域(第一形态)"
    when 933 #時の間:セル第二形態エリア
      story_string += "时之间：沙鲁区域(第二形态)"
    when 934 #時の間:メタルクウラエリア
      story_string += "时之间：金属古拉区域"
    when 935 #時の間:メタルクウラエリア
      story_string += "时之间：金属古拉区域(核心)"
    when 936 #時の間:人造人間13号エリア
      story_string += "时之间：人造人区域(13号・14号・15号)"
    when 937 #時の間:セル最終形態エリア
      story_string += "时之间：沙鲁区域(最终形态)"
    when 999 #時の間
      story_string += "时之间"
    when 2001 #
      story_string += "：" + @game_variables[901].to_s + "回目"
    else
      story_string += "タイトル未設定"
    end
      story_string += "』"
      
    self.contents.font.color.set( 0, 0, 0)
    self.contents.font.shadow = false
    self.contents.font.bold = true
    #self.contents.font.color = normal_color

    self.contents.draw_text(x, y, width+200, WLH, story_string)
  end
  #--------------------------------------------------------------------------
  # ● プレイ時間の描画
  #     x     : 描画先 X 座標
  #     y     : 描画先 Y 座標
  #     width : 幅
  #     align : 配置
  #--------------------------------------------------------------------------
  def draw_playtime(x, y, width, align)
    hour = @total_sec / 60 / 60
    min = @total_sec / 60 % 60
    sec = @total_sec % 60
    time_string = sprintf("%03d:%02d:%02d", hour, min, sec)
    self.contents.font.color.set( 0, 0, 0)
    self.contents.font.shadow = false
    self.contents.font.bold = true
    #self.contents.font.color = normal_color
    self.contents.draw_text(x, y, width, WLH, time_string, 2)
  end
  #--------------------------------------------------------------------------
  # ● 選択状態の設定
  #     selected : 新しい選択状態 (true=選択 false=非選択)
  #--------------------------------------------------------------------------
  def selected=(selected)
    @selected = selected
    update_cursor
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    update_cursor
  end
  #--------------------------------------------------------------------------
  # ● カーソルの更新
  #--------------------------------------------------------------------------
  def update_cursor
    if @selected
      #self.cursor_rect.set(0, 0, @name_width + 8, WLH)
      picture = Cache.picture("アイコン")
      #rect = Rect.new(16*5, 0, 16, 16) #戦闘の横カーソルと同一
      rect = set_yoko_cursor_blink 1#点滅ありで
      self.contents.blt(0,2,picture,rect)
    else
      #picture = Cache.picture("アイコン")
      #rect = Rect.new(16, 0, 16, 16) #ドラゴンボール中赤
      #self.contents.blt(0,2,picture,rect)
      self.contents.fill_rect(0,0,16,18,self.get_back_window_color)
      #self.cursor_rect.empty
    end
  end
  #--------------------------------------------------------------------------
  # ● 周回数表示(セルゲーム編クリアしたデータのみ)
  #-------------------------------------------------------------------------- 
  def draw_laps
    picture = Cache.picture("アイコン")
    #rect = Rect.new(464, 2, 14, 14) #ドラゴンボール中黒
      rect = Rect.new(480, 2, 14, 14) #ドラゴンボール中赤
    if @game_switches[458] == true #セルゲーム編クリアしたか
      self.contents.blt(0,30,picture,rect)
    end  
      
    if @game_switches[586] == true #外伝クリアしたか
      self.contents.blt(16,30,picture,rect)
    end    

    if @game_switches[600] == true #パイクーハン、ブウ倒したか
      self.contents.blt(0,46,picture,rect)
    end  
    
    if @game_switches[854] == true #アラレ倒したか
      self.contents.blt(16,46,picture,rect)
    end  
      
    if @game_switches[860] == true #強くてニューゲーム中
      self.contents.font.color.set( 0, 0, 0)
      self.contents.font.shadow = false
      self.contents.font.bold = true
      #self.contents.font.color = normal_color
      
      #$game_laps += 1
      #p $game_laps.to_s.length
      #case $game_laps.to_s.length
      
      #when 1 #1桁
      #  x = 21
      #when 2 #2桁
      #  x = 10
      #when 3 #3桁
        x = -1
      #end
      #p @game_laps
      self.contents.draw_text(0, 58, 32, 24, "clear")
      #self.contents.draw_text(x, 74, 96, 24, $game_laps.to_s)
      self.contents.draw_text(x, 74, 96, 24, "%03d" % @game_laps.to_s)
    end
  end
  #--------------------------------------------------------------------------
  # ● 能力詳細表示
  #--------------------------------------------------------------------------   
  def output_character(i,x,y) 
    rect,picture = set_character_face 0,@partyc[i]-3,0,@game_switches,@game_variables,@oozaru_flag
    self.contents.blt(64*i+96-64,30,picture,rect)
  end
end
