#==============================================================================
# ■ Scene_Story_So_Far
#------------------------------------------------------------------------------
# 　あらすじ表示
#==============================================================================
class Scene_Story_So_Far < Scene_Base
  include Share
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize()

  end
  #--------------------------------------------------------------------------
  # ● ウインドウ作成
  #--------------------------------------------------------------------------   
  def create_window
    @main_window = Window_Base.new(-16,-16,672,512)
    @main_window.opacity=0
    @main_window.back_opacity=0
    @titale_window = Window_Base.new(220,48,200,80)
    @titale_window.opacity=255
    @titale_window.back_opacity=255
    @titale_window.contents.font.color.set( 0, 0, 0)
    @titale_window.contents.font.size = 24
    @titale_window.contents.draw_text(40,5, 200, 40, "前情提要")
  end
  #--------------------------------------------------------------------------
  # ● ウインドウ開放
  #--------------------------------------------------------------------------   
  def dispose_main_window
    @main_window.dispose
    @main_window = nil
    @titale_window.dispose
    @titale_window = nil
  end 
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    Graphics.fadein(20)
    @z1_scenex = 224           #上背景位置X
    @z1_sceney = 46            #上背景位置Y
    @z1_scrollscenex = 64      #スクロール用上背景位置X
    @z1_scrollsceney = 316      #スクロール用上背景位置Y
    @ene1_x = @z1_scenex + 64 #上キャラ表示基準位置X
    @ene1_y = @z1_sceney + 32 #上キャラ表示基準位置Y
    @play_x = @z1_scenex + 64 #下キャラ(味方)表示基準位置X
    @play_y = @z1_scenex + 82 #下キャラ(味方)表示基準位置Y
    @message_window = Window_Message.new
    @bgm_start_time = Time.now
    @end_prelude_flag = false #前奏完了フラグ
    @scene_scroll_count = 0
    @chare_scroll_count = 0
    @chare_shake_count = 0
    @chare_shake_y = -2
    @msg_output_end = false
    @bgm_name = nil
    create_window
    set_bgm
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  def terminate
    super
    @message_window.dispose
    dispose_main_window
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  # 戻り値 "1" ：(メニュー画面を抜ける)
  #--------------------------------------------------------------------------   
  def update

    super
    
    case $game_variables[43] #あらすじNo
    
    when 0..20,51..80,101 # 0:ドラゴンレーダー取得前,1:ドラゴンレーダー取得後
      #if Time.now - @bgm_start_time >= 3.94 && @end_prelude_flag == false
      #  @end_prelude_flag = true
      #end
      put_story_scene $game_variables[43] #背景表示
      put_story $game_variables[43]       #メッセージ表示
    
    when 21..50
      $scene = Scene_Map.new
 
    end
    @message_window.update            # メッセージウィンドウを更新
    if $game_message.busy == false && @chare_scroll_count > 900
      Graphics.fadeout(30)
      #Audio.bgm_play("Audio/BGM/" + $map_bgm)
      $scene = Scene_Map.new
    end
  end
  #--------------------------------------------------------------------------
  # ● あらすじメッセージ表示
  # 引数：[story_no:あらすじno]
  #--------------------------------------------------------------------------   
  def put_story story_no
    text_list=[]
    text = nil
    x = 0
    case story_no
    
    when 0 #ドラゴンレーダー取得前
      if @msg_output_end == false
      text =
        "地球面临了最大的危机！
        悟空的亲哥哥赛亚人拉蒂兹
        前来侵略地球！

        拉迪兹把悟空的儿子悟饭当成人质
        企图迫使悟空加入他的队伍！！
        悟空一个人根本无法打赢他！！

        就在那时，一位意想不到的人物现身！那就是宿命的对手比克！
        对于比克来说，这个可怕的赛亚人成了他野心的障碍！
        终于，地球上最强的搭档诞生！！
        赶紧用龙珠雷达找到悟饭吧！！！"
      end
    
    when 1 #ドラゴンレーダー取得後
      if @msg_output_end == false
      text =
        "用布尔玛给的龙珠雷达，总算找到了悟饭的位置！
        悟空和比克能够打败强大的赛亚人
        从拉蒂兹手中解救出悟饭吗！？"
      end
      
    when 2 #蛇の道
      if @msg_output_end == false
      text =
        "为了前往界王处接受训练　
        悟空必须赶紧走过漫长漫长的蛇道！
        加快脚步，悟空！
        而且，更强大的赛亚人也会在一年后来到地球！"
      end
      
    when 3 #サンショエリア
      if @msg_output_end == false
      text =
        "为了拯救地球的危机，必须收集龙珠！
        然而，新的敌人正瞄准这些龙珠！
        他们是企图征服世界的卡里克军团！
        绝不能把龙珠交给他们！
        Ｚ战士们分成三组，开始了旅程！
        向北方出发的Z战士们是……"
      end
    when 4 #バブルス修行
      if @msg_output_end == false
      text =
        "在界王的指导下，悟空的修行开始了！
        首先是捉住他的宠物巴布鲁斯！
        不过，这个界王星的重力非常强！身体感觉像铅一样沉重！
        悟空啊！加油！"
      end
    when 5 #ニッキーエリア
      if @msg_output_end == false
      text =
        "Ｚ战士们朝东方前进，追寻龙珠！
        绝不能让龙珠落入卡里克军团手中！"
      end
    when 6 #グレゴリー修行
      if @msg_output_end == false
      text =
        "界王的第二阶段修行是用重重的锤子
        敲击界王的仆人古雷格利…
        古雷格利的速度惊人！
        悟空！加油打吧！！"
      end
    when 7 #ジンジャーエリア
      if @msg_output_end == false
      text =
        "Ｚ战士们朝西方前进，追寻龙珠！
        为了守护地球，Ｚ戦士加油吧！"
      end
    when 8 #ガーリックエリア
      if @msg_output_end == false
      text =
        "终于，Ｚ战士们抵达了卡里克城
        这里是他们的根据地！！
        最后的一颗龙珠就在这里！
        卡里克一伙也会拼死一战！"
      end
    when 9 #ガーリックエリア(３人衆撃破後)
      if @msg_output_end == false
      text =
        "Ｚ战士们击败了卡里克的三人小队：吉加、尼奇和桑修
        现在就剩下卡里克一人了！！！
        围绕最后的龙珠，
        一场激烈的生死搏斗即将开始！"
      end
    when 10 #界王様修行
      if @msg_output_end == false
      text =
        "终于，悟空得以直接接受界王的严格训练
        这是一次艰苦的修行，地球的命运正悬在悟空身上！
        赛亚人们的到来已经迫在眉睫！"
      end
    when 11 #ベジータエリア
      if @msg_output_end == false
      text =
        "终于，赛亚人来了！
        Ｚ战士们能够阻止他们的侵略吗！？        
        悟空在另一个世界的修炼已经结束，他能及时赶到吗！？"
      end
    when 12 #ベジータエリア(サイバイマン撃破後)
      if @msg_output_end == false
      text =
        "拉蒂兹所说的更强大的赛亚人！
        他们的实力如何！？力量又如何！？
        Ｚ战士们能够抵抗他们的力量吗！？
        决战的时刻即将来临！！！"
      end
    when 13 #ベジータエリア(ナッパ撃破後)
      if @msg_output_end == false
      text =
        "Ｚ战士们打败了拥有可怕力量的那巴！
        他们的战斗即将迎来高潮！
        发挥出最后的力量吧！Ｚ战士！"
      end
      
    when 16 #この世で一番強いやつ(氷原エリア)
      if @msg_output_end == false
      text =
        "作为被誉为天才科学家的威洛博士的助手
        克勤博士收集龙珠，从永久冰壁中，
        在威洛博士死去50年后，让他重新复活！

        作为拥有地球上最强的头脑的人
        威洛博士开始寻找地球上最强的人类身体！
        他将目标锁定在被称为武术之神的武天老師龟仙人身上　
        并且把他和布尔玛一同绑架！
        在乌龙的请求下，大家迅速赶来相救
        Ｚ战士们正前往被冰封的鹤舞山
        那里正是威洛博士的要塞！"
      end
    when 17 #この世で一番強いやつ(要塞エリア)
      if @msg_output_end == false
      text =
        "终于，Z战士们抵达了威洛博士的要塞！
        被绑架的亀仙人和布尔玛，他们都平安无事吗！？
        
        赶快，Ｚ战士们！！"
      end
    when 18 #この世で一番強いやつ(バイオ戦士撃破後エリア)
      if @msg_output_end == false
      text =
        "Ｚ战士们成功解救了被绑架的亀仙人和布尔玛
        并打倒了由克勤博士制造的生物战士！
      　
        无论如何，一定要阻止威洛博士的野心！！"
      end  
    when 101 #ラディッツエリア　バーダック編
      if @msg_output_end == false
      text =
        "地球面临了最大的危机！
        巴达克的儿子拉蒂兹
        前来侵略地球！

        拉迪兹把巴达克的孙子悟饭当成人质
        企图迫使巴达克加入他的队伍！！
        巴达克一个人根本无法打赢他！！
        
        就在那时，一位意想不到的人物现身！那就是宿命的对手比克！
        对于比克来说，这个可怕的赛亚人成了他野心的障碍！
        终于，一个与众不同的组合诞生了！！
        赶快用龙珠雷达寻找悟饭！！！"
      end
    end
    
    
    #メッセージ表示
    if @msg_output_end == false
      text.each_line {|line| #改行を読み取り複数行表示する
        line.sub!("￥n", "") # ￥は半角に直す
        line = line.gsub("\r", "")#改行コード？が文字化けするので削除
        line = line.gsub("\n", "")#
        line = line.gsub(" ", "")#半角スペースも削除
        text_list[x]=line
        x += 1
        }
        put_message text_list
        @msg_output_end = true
    end
  end
  #--------------------------------------------------------------------------
  # ● あらすじ画像表示
  # 引数：[story_no:あらすじno]
  #--------------------------------------------------------------------------   
  def put_story_scene story_no
    
    @main_window.contents.clear
    color = set_skn_color 0
    @main_window.contents.fill_rect(0,0,656,496,color)
    
    case story_no
    
    when 0..20,51..80,101
      
      #画像表示
      picture = Cache.picture("Z1_背景_スクロール_海")
      rect = Rect.new(512-@scene_scroll_count*4, 0, 512, 128) # スクロール背景
      
      if story_no == 101
        picture2 = Cache.picture("Z1_イベント_バーダックとゴハン")
      else
        picture2 = Cache.picture("Z1_イベント_ゴクウとゴハン")
      end
      rect2 = Rect.new(0, 0, 96, 66) # イベント
      @main_window.contents.blt(@z1_scrollscenex,@z1_scrollsceney,picture,rect)
      @main_window.contents.blt(@z1_scrollscenex+560-@chare_scroll_count,@z1_scrollsceney+14+@chare_shake_y,picture2,rect2)
      
      #両端を背景色で消す
      @main_window.contents.fill_rect(0,@z1_scrollsceney,@z1_scrollscenex,128,color) #左
      @main_window.contents.fill_rect(@z1_scrollscenex + 512,@z1_scrollsceney,150,128,color) #右
      @main_window.update
      
      @scene_scroll_count += 0.5  #背景スクロール値加算
      
      if @chare_shake_count < 8
        @chare_shake_count += 1     #キャラスクロール値加算
      else
        @chare_shake_count = 1
      end
      
      #背景スクロール128以上スクロールしたら画像が切れるので元に戻す
      if @scene_scroll_count == 128
        @scene_scroll_count = 0
      end
      
      #悟空上下シェイク
      #@main_window.contents.draw_text(0,0, 200, 40, @chare_shake_count)
      #@main_window.contents.draw_text(0,40, 200, 40, @chare_shake_y)
      
      case @chare_shake_count
      
      when 1..4
        @chare_shake_y = +2
      when 5..8
        @chare_shake_y = 0
      end
      
      #悟空移動、真ん中あたりで止め、メッセージが全て完了したら左端までいく
      if @z1_scrollscenex+216 <= @z1_scrollscenex+560-@chare_scroll_count
        @chare_scroll_count += 4
      elsif $game_message.busy == false
        @chare_scroll_count += 6
      end

    end

  end
  #--------------------------------------------------------------------------
  # ● あらすじ曲再生
  #--------------------------------------------------------------------------  
  def set_bgm
    case $game_variables[43] #あらすじNo
    
    when 0..20,51..80,101
      
      if @end_prelude_flag == false
        @bgm_name = "Z1 あらすじ"
      else
        
      end
    
    when 21..50
      @bgm_name = "Z2 あらすじ"
    when 1
      Audio.bgm_play("Audio/BGM/" +"Z1 戦闘前")
    when 2
      Audio.bgm_play("Audio/BGM/" +"Z1 戦闘1")
    when 3
      Audio.bgm_play("Audio/BGM/" +"Z1 戦闘2")
    when 4
      Audio.bgm_play("Audio/BGM/" +"Z1 戦闘ボス1(中ボス)")
    when 5
      Audio.bgm_play("Audio/BGM/" +"Z1 戦闘ボス2(ベジータ)")
    when 6
      Audio.bgm_play("Audio/BGM/" +"Z2 戦闘1(前奏)")
    when 7
      Audio.bgm_play("Audio/BGM/" +"Z2 戦闘2")
    when 8
      Audio.bgm_play("Audio/BGM/" +"Z3 戦闘1")
    when 9
      Audio.bgm_play("Audio/BGM/" +"Z3 戦闘2(ボス)")
    when 10
      Audio.bgm_play("Audio/BGM/" +"Z3 戦闘3(簡易)")
    when 11
      Audio.bgm_play("Audio/BGM/" +"Z2 戦闘2")
    end
    
    Audio.bgm_play("Audio/BGM/" + @bgm_name)
  end

  #--------------------------------------------------------------------------
  # ● 文章の表示
  #引数：[text:表示内容,position:ウインドウ表示位置]
  #--------------------------------------------------------------------------
  def put_message text,position = 1
    unless $game_message.busy
      #$game_message.face_name = ""
      #$game_message.face_index = 0
      #$game_message.background = 0         #背景 0:通常 1:背景暗く 2:透明
      $game_message.position = position
      for x in 0..text.size - 1 
        $game_message.texts.push(text[x])
      end
      set_message_waiting                   # メッセージ待機状態にする
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● メッセージ待機中フラグおよびコールバックの設定
  #--------------------------------------------------------------------------
  def set_message_waiting
    @message_waiting = true
    $game_message.main_proc = Proc.new { @message_waiting = false }
  end
end