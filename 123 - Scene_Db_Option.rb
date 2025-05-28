#==============================================================================
# ■ Scene_Db_Option
#------------------------------------------------------------------------------
# 　カード画面表示
#==============================================================================
class Scene_Db_Option < Scene_Base
  include Icon
  include Share
  Option_win_sizex = 640         #カード一覧ウインドウサイズX
  #Option_win_sizey = 360         #カード一覧ウインドウサイズY
  Option_win_sizey = 374         #カード一覧ウインドウサイズY
  Explanation_win_sizex = 640       #カード説明ウインドウサイズX
  #Explanation_win_sizey = 120       #カード説明ウインドウサイズY
  Explanation_win_sizey = 106       #カード説明ウインドウサイズY
  Explanation_lbx = 16              #カード説明表示基準X
  Explanation_lby = 0               #カード説明表示基準Y
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     call_state : どのプログラムから呼ばれたか 1:戦闘 2:マップ 3:ステータス 9:タイトル
  #--------------------------------------------------------------------------
  def initialize call_state=2 
    @call_state = call_state
    @battle_card_cursor_state = 0     #戦闘カードのカーソル位置
    @window_state = 0         #ウインドウ状態 0:カード選択 1:バトルカード選択
    set_bgm
    @cursorstatex = 0
    @cursorstatey = 0
    
    if call_state == 9 #タイトル画面から開かれたらフラグをON
      if $title_option_open == false
        
        $game_variables[38] = 1 #戦闘メッセージ表示
        $game_variables[31] = 1 #エンカウント設定
      end
      $title_option_open = true
      set_levelup_se
      
      if $title_op_btl_msg != nil
        #2度め以降に変更しても何故か反映されない事の対策
        #バトルメッセージ
        $game_variables[38] = $title_op_btl_msg
        #エンカウント頻度
        $game_variables[31] = $title_op_btl_enc 
        #オープニングカット
        $game_variables[302] = $title_op_op_cut 
        #あらすじカット
        $game_variables[355] = $title_op_arasuzi_cut 
        #メッセージウェイト
        $game_switches[482] = $title_op_msg_wait 
        #メッセージ表示常時高速化
        $game_switches[881] = $title_op_msg_show_fast 
        #メッセージ送り
        $game_variables[357] = $title_op_msg_next 
        #ゲームの高速化
        $game_switches[492] = $title_op_fast_fps
        #カード合成デフォ表示
        $game_variables[462] = $title_op_card_compo_def
        #カード合成で作りたいカードから合成した後に戻る画面ｎ
        $game_variables[463] = $title_op_card_comporeturn_def
        #かばうカットするか
        $game_switches[884] = $title_op_kabau_cut
      end
      
    else
      $title_option_open = false
    end
  end
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    @cursor_state = 0                #カーソル
    @option_line_height = 28          #改行の高さ
    @op_btl_bgm = "op_btl_bgm"        #バトルBGM
    @op_btl_ready_bgm = "op_btl_ready_bgm"        #バトル前BGM
    @op_btl_end_bgm = "op_btl_end_bgm"        #バトル終了後BGM
    @op_btl_mode = "op_btl_mode"        #バトルモード
    @op_btl_scrl = "op_btl_scrl"      #バトル背景スクロール
    @op_meu_bgm = "op_meu_bgm"        #メニューBGM
    @op_btl_spd = "op_btl_spd"          #バトルスピード
    @op_btl_msg = "op_bgl_msg"        #バトルメッセージ
    @op_btl_skl = "op_bgl_skl"        #バトルスキル表示
    @op_btl_skl_slide = "op_bgl_skl_slide"  #バトルスキル表示スライドするか
    @op_meu_skl_put = "op_meu_skl_put"  #能力画面のスキル一覧表示
    @op_btl_enc = "op_btl_enc"        #エンカウント頻度
    @op_btl_enc_se = "op_btl_enc_se"        #エンカウントSE
    @op_btl_dmg = "op_btl_dmg"        #ダメージ位置
    @op_walk_mode = "op_walk_mode"        #歩行モード
    @op_btl_explode = "op_btl_explode"        #戦闘爆発
    @op_win_skn = "op_win_skn"        #ウインドウスキン
    @op_op_cut = "op_op_cut"          #オープニングカット
    @op_msg_wait = "op_msg_wait"      #メッセージウェイト
    @op_msg_show_fast = "op_msg_show_fast"      #メッセージ高速表示
    @op_msg_next = "op_msg_next"      #メッセージ送り
    @op_save_num = "op_save_num"      #セーブファイル数
    @op_btl_diff = "op_btl_diff"      #戦闘難易度
    @op_fast_fps = "op_fast_fps"      #高速化
    @op_arasuzi_cut = "op_arasuzi_cut"      #あらすじカット
    @op_eve_wait = "op_eve_wait"      #イベントのウェイト
    @op_eve_btl_cut = "@op_eve_btl_cut"      #イベント戦闘のカットや初取得のSコンボをカット
    @op_btl_kanashibari = "op_btl_kanashibari"      #かなしばり回数表示
    @op_scon_priority = "op_scon_priority"      #Sコンボ優先度
    @op_levelupse = "op_levelupse"      #レベルアップSE
    @op_evbtl_bgm = "op_evbtl_bgm"        #イベントバトルBGM
    @op_evbtl_ready_bgm = "op_evbtl_ready_bgm"        #イベントバトル前BGM
    @op_card_compo_def = "op_card_compo_def"        #カード合成の初期表示
    @op_card_comporeturn_def = "op_card_comporeturn_def"        #合成完了後に戻る画面
    @op_captozp_bairitu = "op_captozp_bairitu" #重量装置カードの上昇量
    @op_op_kabau_cut = "op_kabau_cut" #かばう演出カットするか
    @op_action_sel_bgm = "op_action_sel_bgm"        #メインBGM
    
    
    #オプション項目設定
    if @call_state != 9
      
      #別モードならオプションを切り替える
      if $game_variables[481] == 0
      
        #標準
        @option_no=[@op_btl_msg,@op_btl_mode,@op_btl_spd,@op_btl_scrl,@op_btl_dmg,@op_btl_skl,@op_btl_skl_slide,@op_btl_bgm,@op_btl_ready_bgm,@op_btl_end_bgm,@op_meu_bgm,@op_meu_skl_put,@op_btl_enc,@op_btl_enc_se,@op_walk_mode,@op_btl_explode,@op_op_cut,@op_arasuzi_cut,@op_msg_wait,@op_msg_show_fast,@op_msg_next,@op_levelupse,@op_win_skn,@op_save_num,@op_fast_fps,@op_btl_kanashibari,@op_scon_priority,@op_card_compo_def,@op_card_comporeturn_def,@op_op_kabau_cut] #オプションの種類
        #周回プレイ中であれば追加
        if $game_switches[860] == true
          @option_no << @op_eve_wait  #イベントのウェイト
          @option_no << @op_eve_btl_cut #イベント戦闘のカットや初取得のSコンボをカット
          @option_no << @op_evbtl_bgm #イベントバトルBGM #BGM名リターン処理を大幅に変更しないといけないからボツ
          @option_no << @op_evbtl_ready_bgm #イベントバトル前BGM
          @option_no << @op_captozp_bairitu #重量装置カードの上昇量
          @option_no << @op_btl_diff      #難易度
        end
      else
        #標準
        @option_no=[@op_btl_msg,@op_btl_mode,@op_btl_spd,@op_btl_scrl,@op_btl_dmg,@op_btl_skl,@op_btl_skl_slide,@op_action_sel_bgm,@op_btl_bgm,@op_btl_ready_bgm,@op_btl_end_bgm,@op_meu_bgm,@op_meu_skl_put,@op_btl_enc_se,@op_btl_explode,@op_op_cut,@op_msg_wait,@op_msg_show_fast,@op_msg_next,@op_levelupse,@op_win_skn,@op_save_num,@op_fast_fps,@op_btl_kanashibari,@op_scon_priority,@op_card_compo_def,@op_card_comporeturn_def,@op_op_kabau_cut] #オプションの種類
        
      end

    else
      #タイトル画面
      @option_no=[@op_btl_msg,@op_btl_enc,@op_op_cut,@op_arasuzi_cut,@op_msg_wait,@op_msg_show_fast,@op_msg_next,@op_fast_fps,@op_card_compo_def,@op_card_comporeturn_def,@op_op_kabau_cut]
    end
    @option_Item_Num = @option_no.size
    @win_skn_max = $game_variables[40] + 1#ウインドウスキン用max
    @win_skn_max = 5
    
    @put_page = 0 #出力ページ
    @put_option_num = [11,12,12]#[11,12,4] #1ページの出力数
    super
    #シナリオ進行度によってファイル名の頭文字を変える
    chk_scenario_progress
    @window_update_flag = true
    chk_battle_bgm_on
    chk_menu_bgm_on
    chk_battle_ready_bgm_on
    chk_action_sel_bgm_on
    create_window
    @s_up_cursor = Sprite.new
    @s_down_cursor = Sprite.new
    set_up_down_cursor
    pre_update
    Graphics.fadein(5)
  end
  
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_sprite
    dispose_window

    #タイトルから設定した時にゲームスタートで反映するように変数に格納する
    #バトルメッセージ
    $title_op_btl_msg = $game_variables[38]
    #エンカウント頻度
    $title_op_btl_enc = $game_variables[31]
    #オープニングカット
    $title_op_op_cut = $game_variables[302]
    #あらすじカット
    $title_op_arasuzi_cut = $game_variables[355]
    #メッセージウェイト
    $title_op_msg_wait = $game_switches[482]
    #メッセージ表示常時高速化
    $title_op_msg_show_fast = $game_switches[881]
    #メッセージ送り
    $title_op_msg_next=$game_variables[357]
    #ゲームの高速化
    $title_op_fast_fps=$game_switches[492]
    #カード合成デフォ表示
    $title_op_card_compo_def=$game_variables[462]
    #カード合成で作りたいカードから合成した後に戻る画面ｎ
    $title_op_card_comporeturn_def=$game_variables[463]
    #かばうカットするか
    $title_op_kabau_cut = $game_switches[884]
  end
  
  #--------------------------------------------------------------------------
  # ● 画面更新
  #--------------------------------------------------------------------------    
  def pre_update
    
    if @window_update_flag == true
      $bgm_btl_random_flag[$game_variables[37]] = 1 if $bgm_btl_random_flag[$game_variables[37]] == nil
      $bgm_evbtl_random_flag[$game_variables[428]] = 1 if $bgm_evbtl_random_flag[$game_variables[428]] == nil
      $bgm_menu_random_flag[$game_variables[36]] = 1 if $bgm_menu_random_flag[$game_variables[36]] == nil
      window_contents_clear
      output_option
      output_option_message
      @window_update_flag = false
      if @result_window != nil
        output_result
      end
    end
    output_cursor
  end
  
  #--------------------------------------------------------------------------
  # ● フレーム更新
  # 戻り値 "1" ：(メニュー画面を抜ける)
  #--------------------------------------------------------------------------   
  def update
    super
    #pre_update
    #カード所持数が0のときはキャンセル以外処理しない
    if Input.trigger?(Input::B)
      if @window_state == 0
        Audio.se_stop
        Audio.me_stop
        #Graphics.fadeout(5)
        
        #タイトル以外から呼ばれた
        if @call_state != 9 
          Audio.bgm_play("Audio/BGM/" + $map_bgm)    # 効果音を再生する
          $scene = Scene_Map.new
        else
          $scene = Scene_Title.new
        end
      end
        
    end  
    
    if Input.trigger?(Input::L)
      @window_update_flag = true
      Audio.se_play("Audio/SE/" + $BGM_CursorMove)    # 効果音を再生する
      @put_page -= 1
      if @put_page == -1
        #最後のページへ
        @put_page = @put_option_num.size - 1
        
        tmp_option_no = 0
        for x in 0..@put_page
          tmp_option_no += @put_option_num[x]
        end
        tmp_option_no -= @put_option_num[@put_page]
        #p tmp_option_no
        #p @cursor_state
        #p @option_no.size
        if @option_no.size - 1 >= (@cursor_state + tmp_option_no + 1)
          #次のページに前のカーソルの行がある
          @cursor_state += tmp_option_no + 1
        else
          @cursor_state = @option_no.size - 1
        end
        
        #p @cursor_state
      else
        #@put_page = 0
        if @put_page == 0
          @cursor_state -= @put_option_num[@put_page] + 1
        else
          #何故か1ページのと指定数を変えないといけないので処理を分ける
          @cursor_state -= @put_option_num[@put_page]
        end
      end
      move_cursor 0
    end
    
    if Input.trigger?(Input::R)
      @window_update_flag = true
      Audio.se_play("Audio/SE/" + $BGM_CursorMove)    # 効果音を再生する
      @put_page += 1
      if @put_page < @put_option_num.size
        #最大ページいない
        if @option_no.size - 1 >= (@cursor_state + @put_option_num[0] + 1)
          #次のページに前のカーソルの行がある
          if @put_page == 1
            @cursor_state += @put_option_num[@put_page-1] + 1
          else
            #何故か1ページのと指定数を変えないといけないので処理を分ける
            @cursor_state += @put_option_num[@put_page-1]
          end
        else
          @cursor_state = @option_no.size - 1
        end
      else
        tmp_option_no = 0
        for x in 0..(@put_option_num.size - 2)
          tmp_option_no += @put_option_num[x]
        end
        
        @cursor_state -= tmp_option_no + 1
        @put_page = 0        
      end

      move_cursor 0
    end
    
    if Input.trigger?(Input::C)
      
      case @option_no[@cursor_state]
      
      when @op_btl_bgm
        if $option_battle_bgm_name != ""
          if $option_battle_bgm_name.include?("_user") == false
            Audio.bgm_play("Audio/BGM/" + $option_battle_bgm_name)    # 効果音を再生する
          else
            Audio.bgm_play("Audio/MYBGM/" + $option_battle_bgm_name)    # 効果音を再生する
          end
        end
      when @op_evbtl_bgm
        if $option_evbattle_bgm_name != ""
          if $option_evbattle_bgm_name.include?("_user") == false
            Audio.bgm_play("Audio/BGM/" + $option_evbattle_bgm_name)    # 効果音を再生する
          else
            Audio.bgm_play("Audio/MYBGM/" + $option_evbattle_bgm_name)    # 効果音を再生する
          end
        end
      when @op_btl_ready_bgm
        if $option_battle_ready_bgm_name != ""
          if $option_battle_ready_bgm_name.include?("_user") == false
            Audio.bgm_play("Audio/BGM/" + $option_battle_ready_bgm_name)    # 効果音を再生する
          else
            
            Audio.bgm_play("Audio/MYBGM/" + $option_battle_ready_bgm_name)    # 効果音を再生する
          end
        end
      
      when @op_evbtl_ready_bgm
        if $option_evbattle_ready_bgm_name != ""
          if $option_evbattle_ready_bgm_name.include?("_user") == false
            Audio.bgm_play("Audio/BGM/" + $option_evbattle_ready_bgm_name)    # 効果音を再生する
          else
            
            Audio.bgm_play("Audio/MYBGM/" + $option_evbattle_ready_bgm_name)    # 効果音を再生する
          end
        end
      
      when @op_btl_end_bgm
        if $option_battle_end_bgm_name != "" #&& $option_battle_end_bgm_name != "なし"
          Audio.me_stop
          Audio.me_play("Audio/" + $option_battle_end_bgm_name)    # 効果音を再生する
        end
      when @op_meu_bgm
        if $option_menu_bgm_name != ""
          if $option_menu_bgm_name.include?("_user") == false
            Audio.bgm_play("Audio/BGM/" + $option_menu_bgm_name)    # 効果音を再生する
          else
            Audio.bgm_play("Audio/MYBGM/" + $option_menu_bgm_name)    # 効果音を再生する
          end
        end
      when @op_action_sel_bgm
        if $option_action_sel_bgm_name != ""
          if $option_action_sel_bgm_name.include?("_user") == false
            Audio.bgm_play("Audio/BGM/" + $option_action_sel_bgm_name)    # 効果音を再生する
          else
            Audio.bgm_play("Audio/MYBGM/" + $option_action_sel_bgm_name)    # 効果音を再生する
          end
        end
      when @op_levelupse
        #RPG::BGM.fade(0 * 1000)
        Audio.me_stop
        Audio.me_play("Audio/SE/" +$BGM_levelup_se)    # 効果音を再生する
        #Graphics.wait(120)
        #Audio.bgm_play("Audio/BGM/" + $option_menu_bgm_name)    # 効果音を再生する
      
      when @op_btl_enc_se
        #RPG::BGM.fade(0 * 1000)
        Audio.me_stop
        Audio.me_play("Audio/SE/" +$BGM_encount)    # 効果音を再生する
        #Graphics.wait(120)
        #Audio.bgm_play("Audio/BGM/" + $option_menu_bgm_name)    # 効果音を再生する
      end
    end
    
    if Input.trigger?(Input::Y)
      if $game_switches[111] == false
        @window_update_flag = true
        case @option_no[@cursor_state]
        
        when @op_btl_bgm #戦闘曲　ランダムオンオフ
          if $game_variables[37] >= 2 #ランダムとデフォルト以外なら
            Audio.se_play("Audio/SE/" + $BGM_CursorOn)    # 効果音を再生する
            $bgm_btl_random_flag[$game_variables[37]] = -$bgm_btl_random_flag[$game_variables[37]]
          end
        when @op_evbtl_bgm #戦闘曲　ランダムオンオフ
          if $game_variables[428] >= 2 #ランダムとデフォルト以外なら
            Audio.se_play("Audio/SE/" + $BGM_CursorOn)    # 効果音を再生する
            $bgm_evbtl_random_flag[$game_variables[428]] = -$bgm_evbtl_random_flag[$game_variables[428]]
          end
        when @op_meu_bgm #メニュー曲　ランダムオンオフ
          if $game_variables[36] >= 2 #ランダムとデフォルト以外なら
            Audio.se_play("Audio/SE/" + $BGM_CursorOn)    # 効果音を再生する
            $bgm_menu_random_flag[$game_variables[36]] = -$bgm_menu_random_flag[$game_variables[36]]
          end
        end
      end
      
    end  
    
    if Input.trigger?(Input::DOWN)
      #if @window_state == 0
        Audio.se_play("Audio/SE/" + $BGM_CursorMove)    # 効果音を再生する
        move_cursor 2
      #end
    end
    if Input.trigger?(Input::UP)
      #if @window_state == 0
        Audio.se_play("Audio/SE/" + $BGM_CursorMove)    # 効果音を再生する
        move_cursor 8
      #end
    end
    if Input.trigger?(Input::RIGHT)
      Audio.se_play("Audio/SE/" + $BGM_CursorMove)    # 効果音を再生する
      
      case @option_no[@cursor_state]
      when @op_btl_scrl #戦闘背景スクロール
        if $game_variables[35] == 0
          $game_variables[35] = 1
        else
          $game_variables[35] = 0
        end
      when @op_btl_msg #戦闘メッセージ
        if $game_variables[38] == 0
          $game_variables[38] = 1
        else
          $game_variables[38] = 0
        end
      when @op_btl_mode #戦闘モード
        if $game_variables[30] == 0
          $game_variables[30] = 1
        else
          $game_variables[30] = 0
        end
      when @op_btl_dmg #ダメージ表示位置
        if $game_variables[29] == 2
          $game_variables[29] = 0
        else
          $game_variables[29] += 1
        end
      when @op_btl_skl #発動スキル表示
        if $game_variables[351] == 3
          $game_variables[351] = 0
        else
          $game_variables[351] += 1
        end
      when @op_btl_skl_slide #発動スキル表示
        if $game_variables[352] == 0
          $game_variables[352] = 1
        else
          $game_variables[352] = 0
        end
      when @op_meu_skl_put #スキル一覧表示
        if $game_variables[354] == 0
          $game_variables[354] = 1
        else
          $game_variables[354] = 0
        end
      when @op_btl_enc #エンカウント頻度
        if $game_variables[31] == 2
          $game_variables[31] = 0
        else
          $game_variables[31] += 1
        end
      when @op_btl_enc_se #エンカウントSE
        if $game_variables[28] == 3
          $game_variables[28] = 0
        else
          $game_variables[28] += 1
        end
        set_encount_se
      when @op_walk_mode #歩行モード(Z1_2-オリジナル)
        if $game_switches[461] == false
          $game_switches[461] = true
        else
          $game_switches[461] = false
        end
      when @op_btl_explode #戦闘技爆発
        if $game_switches[463] == false
          $game_switches[463] = true
        else
          $game_switches[463] = false
        end
      when @op_btl_kanashibari #かなしばり表示
        if $game_variables[356] == 3
          $game_variables[356] = 0
        else
          $game_variables[356] += 1
        end
      when @op_scon_priority #Sコンボ発動優先度
        if $game_variables[358] == 0
          $game_variables[358] = 1
        else
          $game_variables[358] = 0
        end
      when @op_msg_wait #メッセージウェイト
        if $game_switches[482] == false
          $game_switches[482] = true
        else
          $game_switches[482] = false
        end
      when @op_msg_show_fast #オプション_メッセージ表示常時高速化ON
        if $game_switches[881] == false
          $game_switches[881] = true
        else
          $game_switches[881] = false
        end
      when @op_msg_next #オプション_メッセージ送りの方法
        if $game_variables[357] == 1
          $game_variables[357] = 0
        else
          $game_variables[357] += 1
        end
      when @op_levelupse #レベルアップSE
        if $game_variables[427] == 3
          $game_variables[427] = 0
        else
          $game_variables[427] += 1
        end
        set_levelup_se
      when @op_win_skn #ウインドウスキン
        
        if $game_variables[83] == @win_skn_max
          $game_variables[83] = 0
        else
          $game_variables[83] += 1
        end
        set_skn
        chg_opt_skn
        $game_switches[38] = true
      when @op_btl_bgm #戦闘曲
        if $game_switches[111] == false
          loop_x = $game_variables[37]
          loop_end = false
          begin
            loop_x += 1
            if $max_set_battle_bgm < loop_x
              loop_x = 0            
            end
              
            if $battle_bgm_on[loop_x] == true
              $game_variables[37] = loop_x
              loop_end = true
            end
          end while loop_end == false
        end
      when @op_evbtl_bgm #イベント戦闘曲
        if $game_switches[111] == false
          loop_x = $game_variables[428]
          loop_end = false
          begin
            loop_x += 1
            if $max_set_battle_bgm < loop_x
              loop_x = 0            
            end
              
            if $battle_bgm_on[loop_x] == true
              $game_variables[428] = loop_x
              loop_end = true
            end
          end while loop_end == false
        end
      when @op_btl_ready_bgm #戦闘前曲
        if $game_switches[111] == false
          loop_x = $game_variables[319]
          loop_end = false
          begin
            loop_x += 1
            if $max_btl_ready_bgm < loop_x
              loop_x = 0            
            end
              
            if $battle_ready_bgm_on[loop_x] == true
              $game_variables[319] = loop_x
              loop_end = true
            end
          end while loop_end == false
        end
      when @op_evbtl_ready_bgm #イベント戦闘前曲
        if $game_switches[111] == false
          loop_x = $game_variables[429]
          loop_end = false
          begin
            loop_x += 1
            if $max_btl_ready_bgm < loop_x
              loop_x = 0            
            end
              
            if $battle_ready_bgm_on[loop_x] == true
              $game_variables[429] = loop_x
              loop_end = true
            end
          end while loop_end == false
        end
      when @op_btl_end_bgm #戦闘終了曲
        if $game_switches[111] == false
          if $game_variables[103] >= $max_btl_end_bgm
            $game_variables[103] = 0
          else
            $game_variables[103] += 1
          end
        end
      when @op_action_sel_bgm #行動選択画面の曲
        loop_x = $game_variables[475]
        loop_end = false
        
        begin
          loop_x += 1
          if $max_action_sel_bgm < loop_x
            loop_x = 0            
          end
            
          if $action_sel_bgm_on[loop_x] == true
            $game_variables[475] = loop_x
            loop_end = true
          end
        end while loop_end == false
        #ここでセットしないと画面に戻った時に適用されない
        set_action_sel_bgm_name
        $map_bgm = $option_action_sel_bgm_name

      when @op_meu_bgm #メニュー曲
        if $game_switches[111] == false
          loop_x = $game_variables[36]
          loop_end = false
          begin
            loop_x += 1
            if $max_set_menu_bgm < loop_x
              loop_x = 0            
            end
              
            if $menu_bgm_on[loop_x] == true
              $game_variables[36] = loop_x
              loop_end = true
            end
          end while loop_end == false
=begin
          if $game_variables[36] >= $max_menu_bgm
            $game_variables[36] = 0
          else
            $game_variables[36] += 1
          end
=end
        end
        
      when @op_op_cut #OPカット  
        if $game_variables[302] == 0
          $game_variables[302] = 1
        else
          $game_variables[302] = 0
        end
        $op_cut = $game_variables[302]
      when @op_arasuzi_cut #あらすじカット
        setno = 355
        if $game_variables[setno] == 0
          $game_variables[setno] = 1
        else
          $game_variables[setno] = 0
        end
        #$op_arasuzi_cut = $game_variables[setno]
      when @op_btl_spd #戦闘スピード  
        if $game_variables[303] == 0
          $game_variables[303] = 1
        else
          $game_variables[303] = 0
        end
        
      when @op_save_num #セーブデータ数 
        if $ini_savedata_num >= 255
          $ini_savedata_num = 3
        else
          $ini_savedata_num += 3
        end
        $EXMNU_INCSF_FILE_MAX = $ini_savedata_num
      when @op_fast_fps #高速化の使用
        if $game_switches[492] == false
          $game_switches[492] = true
        else
          $game_switches[492] = false
        end
      when @op_card_compo_def #カード合成の初期表示  
        if $game_variables[462] == 0
          $game_variables[462] = 1
        else
          $game_variables[462] = 0
        end
      when @op_card_comporeturn_def #カード合成後の戻り画面  
        if $game_variables[463] == 0
          $game_variables[463] = 1
        else
          $game_variables[463] = 0
        end
      when @op_eve_wait #イベントウェイト
        if $game_switches[882] == false
          $game_switches[882] = true
        else
          $game_switches[882] = false
        end
      when @op_eve_btl_cut #イベント戦闘、Sコンボ
        if $game_switches[883] == false
          $game_switches[883] = true
        else
          $game_switches[883] = false
        end  
      when @op_captozp_bairitu #重力装置のCAP上昇量
        
        case $game_variables[471]
        
        when 0..2
          $game_variables[471] += 1
        when 3
          $game_variables[471] = 0
        end

      when @op_btl_diff #戦闘難易度
        if $game_variables[353] == $game_laps
          $game_variables[353] = 0
        else
          $game_variables[353] += 1
        end
        #敵のパラメータ取得
        KGC::LimitBreak.set_enemy_parameters
        KGC::LimitBreak.revise_enemy_parameters
      when @op_op_kabau_cut #かばう演出カットするか
        if $game_switches[884] == false
          $game_switches[884] = true
        else
          $game_switches[884] = false
        end
      end
    end
    if Input.trigger?(Input::LEFT)
      Audio.se_play("Audio/SE/" + $BGM_CursorMove)    # 効果音を再生する
      case @option_no[@cursor_state]
      
      when @op_btl_scrl #戦闘背景スクロール
        if $game_variables[35] == 0
          $game_variables[35] = 1
        else
          $game_variables[35] = 0
        end
      when @op_btl_msg #戦闘メッセージ
        if $game_variables[38] == 0
          $game_variables[38] = 1
        else
          $game_variables[38] = 0
        end
      when @op_btl_mode #戦闘モード
        if $game_variables[30] == 0
          $game_variables[30] = 1
        else
          $game_variables[30] = 0
        end
      when @op_btl_dmg #ダメージ表示位置
        if $game_variables[29] == 0
          $game_variables[29] = 2
        else
          $game_variables[29] -= 1
        end
      when @op_btl_skl #発動スキル表示
        if $game_variables[351] == 0
          $game_variables[351] = 3
        else
          $game_variables[351] -= 1
        end
      when @op_meu_skl_put #スキル一覧表示
        if $game_variables[354] == 0
          $game_variables[354] = 1
        else
          $game_variables[354] = 0
        end
      when @op_btl_skl_slide #発動スキル表示スライドするか
        if $game_variables[352] == 0
          $game_variables[352] = 1
        else
          $game_variables[352] = 0
        end
      when @op_btl_enc #エンカウント頻度
        if $game_variables[31] == 0
          $game_variables[31] = 2
        else
          $game_variables[31] -= 1
        end
      when @op_btl_enc_se #エンカウントSE
        if $game_variables[28] == 0
          $game_variables[28] = 3
        else
          $game_variables[28] -= 1
        end
        set_encount_se
      when @op_walk_mode #歩行モード(Z1_2-オリジナル)
        if $game_switches[461] == false
          $game_switches[461] = true
        else
          $game_switches[461] = false
        end
      when @op_btl_explode #戦闘技爆発
        if $game_switches[463] == false
          $game_switches[463] = true
        else
          $game_switches[463] = false
        end
      when @op_btl_kanashibari #かなしばり表示
        if $game_variables[356] == 0
          $game_variables[356] = 3
        else
          $game_variables[356] -= 1
        end
      when @op_scon_priority #Sコンボ発動優先度
        if $game_variables[358] == 0
          $game_variables[358] = 1
        else
          $game_variables[358] = 0
        end
      when @op_msg_wait #メッセージウェイト
        if $game_switches[482] == false
          $game_switches[482] = true
        else
          $game_switches[482] = false
        end
      when @op_msg_show_fast #オプション_メッセージ表示常時高速化ON
        if $game_switches[881] == false
          $game_switches[881] = true
        else
          $game_switches[881] = false
        end
      when @op_msg_next #オプション_メッセージ送りの方法
        if $game_variables[357] == 0
          $game_variables[357] = 1
        else
          $game_variables[357] -= 1
        end
      when @op_levelupse #レベルアップSE
        if $game_variables[427] == 0
          $game_variables[427] = 3
        else
          $game_variables[427] -= 1
        end
        set_levelup_se
      when @op_win_skn #ウインドウスキン
        
        if $game_variables[83] == 0
          $game_variables[83] = @win_skn_max
        else
          $game_variables[83] -= 1
        end
        set_skn
        chg_opt_skn
        $game_switches[38] = true
      when @op_btl_bgm #戦闘曲
        if $game_switches[111] == false
          loop_x = $game_variables[37]
          loop_end = false
          begin
            loop_x -= 1
            if 0 > loop_x
              loop_x = $max_set_battle_bgm            
            end
              
            if $battle_bgm_on[loop_x] == true
              $game_variables[37] = loop_x
              loop_end = true
            end
          end while loop_end == false
        end
      when @op_evbtl_bgm #イベント戦闘曲
        if $game_switches[111] == false
          loop_x = $game_variables[428]
          loop_end = false
          begin
            loop_x -= 1
            if 0 > loop_x
              loop_x = $max_set_battle_bgm            
            end
              
            if $battle_bgm_on[loop_x] == true
              $game_variables[428] = loop_x
              loop_end = true
            end
          end while loop_end == false
        end
      when @op_btl_ready_bgm #戦闘前曲
        if $game_switches[111] == false
          loop_x = $game_variables[319]
          loop_end = false
          begin
            loop_x -= 1
            if 0 > loop_x
              loop_x = $max_btl_ready_bgm  
            end
              
            if $battle_ready_bgm_on[loop_x] == true
              $game_variables[319] = loop_x
              loop_end = true
            end
          end while loop_end == false
        end
      when @op_evbtl_ready_bgm #イベント戦闘前曲
        if $game_switches[111] == false
          loop_x = $game_variables[429]
          loop_end = false
          begin
            loop_x -= 1
            if 0 > loop_x
              loop_x = $max_btl_ready_bgm  
            end
              
            if $battle_ready_bgm_on[loop_x] == true
              $game_variables[429] = loop_x
              loop_end = true
            end
          end while loop_end == false
        end
      when @op_btl_end_bgm #戦闘終了曲
        if $game_switches[111] == false
          if $game_variables[103] == 0
            $game_variables[103] = $max_btl_end_bgm
          else
            $game_variables[103] -= 1
          end
        end
      when @op_action_sel_bgm #行動選択画面の曲
        loop_x = $game_variables[475]
        loop_end = false
        begin
          loop_x -= 1
          if 0 > loop_x
            loop_x = $max_action_sel_bgm
          end
            
          if $action_sel_bgm_on[loop_x] == true
            $game_variables[475] = loop_x
            loop_end = true
          end
        end while loop_end == false
        #ここでセットしないと画面に戻った時に適用されない
        set_action_sel_bgm_name
        $map_bgm = $option_action_sel_bgm_name
      when @op_meu_bgm #メニュー曲
        if $game_switches[111] == false
          loop_x = $game_variables[36]
          loop_end = false
          begin
            loop_x -= 1
            if 0 > loop_x
              loop_x = $max_set_menu_bgm            
            end
              
            if $menu_bgm_on[loop_x] == true
              $game_variables[36] = loop_x
              loop_end = true
            end
          end while loop_end == false
        end
=begin
        if $game_switches[111] == false
          if $game_variables[36] == 0
            $game_variables[36] = $max_menu_bgm
          else
            $game_variables[36] -= 1
          end
        end
=end
      when @op_op_cut #OPカット  
        if $game_variables[302] == 0
          $game_variables[302] = 1
        else
          $game_variables[302] = 0
        end
        $op_cut = $game_variables[302]
      when @op_arasuzi_cut #あらすじカット
        setno = 355
        if $game_variables[setno] == 0
          $game_variables[setno] = 1
        else
          $game_variables[setno] = 0
        end
      when @op_btl_spd #戦闘スピード  
        if $game_variables[303] == 0
          $game_variables[303] = 1
        else
          $game_variables[303] = 0
        end
      when @op_save_num #セーブデータ数 
        if $ini_savedata_num <= 3
          $ini_savedata_num = 255
        else
          $ini_savedata_num -= 3
        end
        $EXMNU_INCSF_FILE_MAX = $ini_savedata_num
      when @op_fast_fps #高速化の使用
        if $game_switches[492] == false
          $game_switches[492] = true
        else
          $game_switches[492] = false
        end
      when @op_card_compo_def #カード合成の初期表示  
        if $game_variables[462] == 0
          $game_variables[462] = 1
        else
          $game_variables[462] = 0
        end
      when @op_card_comporeturn_def #カード合成後の戻り画面  
        if $game_variables[463] == 0
          $game_variables[463] = 1
        else
          $game_variables[463] = 0
        end
      when @op_eve_wait #イベントウェイト
        if $game_switches[882] == false
          $game_switches[882] = true
        else
          $game_switches[882] = false
        end
      when @op_eve_btl_cut #イベント戦闘、Sコンボ
        if $game_switches[883] == false
          $game_switches[883] = true
        else
          $game_switches[883] = false
        end  
      when @op_captozp_bairitu #重力装置のCAP上昇量
        
        case $game_variables[471]
        
        when 0
          $game_variables[471] = 3
        when 1..3
          $game_variables[471] -= 1
        end
      when @op_btl_diff #戦闘難易度
        if $game_variables[353] == 0
          $game_variables[353] = $game_laps
        else
          $game_variables[353] -= 1
        end
        #敵のパラメータ取得
        KGC::LimitBreak.set_enemy_parameters
        KGC::LimitBreak.revise_enemy_parameters
      when @op_op_kabau_cut #かばう演出カットするか
        if $game_switches[884] == false
          $game_switches[884] = true
        else
          $game_switches[884] = false
        end
      end

    end

     @window_update_flag = true if Input.dir8 != 0 #何かカーソルを押したら画面を更新フラグをON
     pre_update
  end
   
  #--------------------------------------------------------------------------
  # ● オプション画面のスキン変更
  #--------------------------------------------------------------------------  
  def chg_opt_skn
    @option_window.refresh
    @explanation_window.refresh
    
  end
  #--------------------------------------------------------------------------
  # ● ウインドウ開放
  #--------------------------------------------------------------------------    
  def dispose_window
    @option_window.dispose
    @option_window = nil
    @explanation_window.dispose
    @explanation_window = nil
  end 
  
  #--------------------------------------------------------------------------
  # ● ウインドウ内容クリア
  #--------------------------------------------------------------------------    
  def window_contents_clear
    @option_window.contents.clear
    @explanation_window.contents.clear
  end
  #--------------------------------------------------------------------------
  # ● ウインドウ作成
  #--------------------------------------------------------------------------   
  def create_window
    @option_window = Window_Base.new(0,Explanation_win_sizey,Option_win_sizex,Option_win_sizey)
    @option_window.opacity=255
    @option_window.back_opacity=255
    @option_window.contents.font.color.set( 0, 0, 0)
    #@option_window.contents.font.shadow = false
    #@option_window.contents.font.bold = true
    #@option_window.contents.font.name = ["ＭＳ ゴシック"]
    #@option_window.contents.font.size = 17
    @explanation_window = Window_Base.new(0,0,Explanation_win_sizex,Explanation_win_sizey)
    @explanation_window.opacity=255
    @explanation_window.back_opacity=255
    @explanation_window.contents.font.color.set( 0, 0, 0)
    #@option_window.contents.font.shadow = false
    #@option_window.contents.font.bold = true
    #@option_window.contents.font.name = ["ＭＳ ゴシック"]
    #@option_window.contents.font.size = 17
  end
  #--------------------------------------------------------------------------
  # ● オプション表示
  #--------------------------------------------------------------------------
  def output_option
    # オプション表示
    i = 0
    option_txt = ""
    puts = 0
    pute = 0
    if @put_page == 0
      #最初のページ
      pute = @put_option_num[@put_page]
    else
      tmp_put_option_num = 0
      
      for x in 0..@put_option_num.size - 1
        tmp_put_option_num += @put_option_num[x]
        if @cursor_state <= tmp_put_option_num
          break
        end
      end
      #p @cursor_state
#      if @put_page != (@put_option_num.size - 1)
      #途中のページ
      puts = tmp_put_option_num - @put_option_num[@put_page]
      pute = tmp_put_option_num#@option_no.size

      #3ページ目以降は何故か追加しないとずれるので追加する
      if @put_page > 1
        puts += 1
        pute += 1
      end
      #p puts
      #p pute
#      else
      #最後のページ
      #途中のページ
#        puts = tmp_put_option_num
#        pute = tmp_put_option_num
#      end
    end
    
    for i in puts..pute
      case @option_no[i]
      
        when @op_btl_msg
          option_txt = "战斗信息　　　　："
          if $game_variables[38] == 0
            option_txt += "自动" 
          else
            option_txt += "手动" 
          end
        when @op_btl_mode
          option_txt = "战斗模式　　　　："
          if $game_variables[30] == 0
            option_txt += "手动" 
          else
            option_txt += "自动" 
          end
        when @op_btl_dmg
          option_txt = "伤害显示　　　　："
          if $game_variables[29] == 0
            option_txt += "下"
          elsif $game_variables[29] == 1
            option_txt += "上"
          else
            option_txt += "两侧" 
          end
        when @op_btl_skl
          option_txt = "发动技能显示　　："
          if $game_variables[351] == 0
            option_txt += "全部"
          elsif $game_variables[351] == 1
            option_txt += "攻击时"
          elsif $game_variables[351] == 2
            option_txt += "防御时"
          else
            option_txt += "不显示" 
          end
        when @op_btl_skl_slide
          option_txt = "技能显示方法　　："
          if $game_variables[352] == 0
            option_txt += "滑动"
          else $game_variables[352] == 1
            option_txt += "固定位置"
          end
        when @op_btl_bgm
          option_txt = "战斗ＢＧＭ　　　："
          @option_window.contents.draw_text(16,@option_line_height.to_i*i, 640, @option_line_height, option_txt.to_s)
          option_txt = ""
          if $bgm_btl_random_flag[$game_variables[37]] == 1 || $game_switches[111] == true
            @option_window.contents.font.color.set( 0, 0, 0)
          else
            @option_window.contents.font.color.set( 128, 128, 128)
          end
          option_txt += set_battle_bgm_name
          #@option_window.contents.draw_text(171+16,@option_line_height.to_i*i, 434, @option_line_height, option_txt.to_s)
          @option_window.contents.draw_text(171+8,@option_line_height.to_i*i, 434, @option_line_height, option_txt.to_s)
          @option_window.contents.font.color.set( 0, 0, 0)

        when @op_evbtl_bgm
          option_txt = "事件战斗ＢＧＭ　："
          puttxt = 0 #テキスト出力位置調整
          if @put_page == (@put_option_num.size - 1)
            puttxt = tmp_put_option_num - @put_option_num[@put_page] + 1
          elsif @put_page != 0
            puttxt = @put_option_num[@put_page-1] + 1
          end
          @option_window.contents.draw_text(16,@option_line_height.to_i*(i - puttxt), 640, @option_line_height, option_txt.to_s)
          option_txt = ""
          if $bgm_evbtl_random_flag[$game_variables[428]] == 1 || $game_switches[111] == true
            @option_window.contents.font.color.set( 0, 0, 0)
          else
            @option_window.contents.font.color.set( 128, 128, 128)
          end
          option_txt += set_battle_bgm_name false,1
          #@option_window.contents.draw_text(171+16,@option_line_height.to_i*i, 434, @option_line_height, option_txt.to_s)
          @option_window.contents.draw_text(171+8,@option_line_height.to_i*(i - puttxt), 434, @option_line_height, option_txt.to_s)
          @option_window.contents.font.color.set( 0, 0, 0)
        when @op_btl_ready_bgm
          option_txt = "战斗前ＢＧＭ　　："
          @option_window.contents.draw_text(16,@option_line_height.to_i*i, 640, @option_line_height, option_txt.to_s)
          option_txt = ""
          option_txt += set_battle_ready_bgm_name
          #@option_window.contents.draw_text(171+16,@option_line_height.to_i*i, 434, @option_line_height, option_txt.to_s)
          @option_window.contents.draw_text(171+8,@option_line_height.to_i*i, 434, @option_line_height, option_txt.to_s)
          @option_window.contents.font.color.set( 0, 0, 0)
        when @op_evbtl_ready_bgm
          option_txt = "事件战斗前ＢＧＭ："
          puttxt = 0 #テキスト出力位置調整
          if @put_page == (@put_option_num.size - 1)
            puttxt = tmp_put_option_num - @put_option_num[@put_page] + 1
          elsif @put_page != 0
            puttxt = @put_option_num[@put_page-1] + 1
          end
          @option_window.contents.draw_text(16,@option_line_height.to_i*(i - puttxt), 640, @option_line_height, option_txt.to_s)
          option_txt = ""
          option_txt += set_battle_ready_bgm_name false,1
          #@option_window.contents.draw_text(171+16,@option_line_height.to_i*i, 434, @option_line_height, option_txt.to_s)
          @option_window.contents.draw_text(171+8,@option_line_height.to_i*(i - puttxt), 434, @option_line_height, option_txt.to_s)
          @option_window.contents.font.color.set( 0, 0, 0)
        when @op_btl_end_bgm
          option_txt = "战斗结束ＢＧＭ　：  "
          option_txt += set_battle_end_bgm_name
        when @op_meu_bgm
          option_txt = "菜单ＢＧＭ　　　："
          #option_txt += set_menu_bgm_name
          @option_window.contents.draw_text(16,@option_line_height.to_i*i, 640, @option_line_height, option_txt.to_s)
          option_txt = ""
          if $bgm_menu_random_flag[$game_variables[36]] == 1 || $game_switches[111] == true
            @option_window.contents.font.color.set( 0, 0, 0)
          else
            @option_window.contents.font.color.set( 128, 128, 128)
          end
          
          option_txt += set_menu_bgm_name
          #@option_window.contents.draw_text(171+16,@option_line_height.to_i*i, 420, @option_line_height, option_txt.to_s)
          @option_window.contents.draw_text(171+8,@option_line_height.to_i*i, 420, @option_line_height, option_txt.to_s)
          @option_window.contents.font.color.set( 0, 0, 0)
          #option_txt = ""
        when @op_action_sel_bgm
          option_txt = "行动选择ＢＧＭ　："
          #option_txt += set_menu_bgm_name
          @option_window.contents.draw_text(16,@option_line_height.to_i*i, 640, @option_line_height, option_txt.to_s)
          option_txt = ""
          option_txt += set_action_sel_bgm_name
          @option_window.contents.draw_text(171+8,@option_line_height.to_i*i, 450, @option_line_height, option_txt.to_s)
          @option_window.contents.font.color.set( 0, 0, 0)
          #option_txt = ""
        when @op_btl_scrl #戦闘背景スクロール
          option_txt = "背景滚动　　　　："
          if $game_variables[35] == 0
            option_txt += "关闭" 
          else
            option_txt += "打开" 
          end
        when @op_meu_skl_put #能力画面スキル一覧
          option_txt = "技能一览表示　　："
          if $game_variables[354] == 0
            option_txt += "全部" 
          else
            option_txt += "可装备的最高等级（包括取得中）" 
          end
        
        when @op_btl_enc #エンカウント頻度
          option_txt = "遇敌　　　　　　："
          if $game_variables[31] == 0
            option_txt += "少"
          elsif $game_variables[31] == 1
            option_txt += "普通"
          else
            option_txt += "多" 
          end
        when @op_btl_enc_se #エンカウント音
          option_txt = "遇敌音乐　　　　："
          if $game_variables[28] == 0
            option_txt += "DBZ 強襲！サイヤ人！"
          elsif $game_variables[28] == 1
            option_txt += "DBZ3 烈戦人造人間"
          elsif $game_variables[28] == 2
            option_txt += "DBZ 超サイヤ伝説"
          elsif $game_variables[28] == 3
            option_txt += "DBZ 悟空激闘伝"
          else
          end
        when @op_btl_kanashibari #かなしばり
          option_txt = "束缚状态表示　　："
          case $game_variables[356]
          
          when 0
            option_txt += "全部显示"
          when 1
            option_txt += "只显示我方"
          when 2
            option_txt += "只显示敌人"
          when 3
            option_txt += "不显示"
          else
            option_txt += "不显示"
          end
        when @op_scon_priority #Sコンボ発動優先度
          option_txt = "组合技发动优先级："
          case $game_variables[358]
          
          when 0
            option_txt += " 默认值"
          when 1
            option_txt += "指定顺序"
          end
        when @op_walk_mode #歩行モード(Z1_2-オリジナル)
          option_txt = "步行模式　　　　："
          if $game_switches[461] == false
            option_txt += "默认值"
          else
            option_txt += "DBZ2 激神フリーザ！！"
          end
        when @op_btl_explode #爆発割合変化
          option_txt = "战斗时爆炸变化　："
          if $game_switches[463] == false
            option_txt += "关闭"
          else
            option_txt += "打开"
          end
        when @op_levelupse #レベルアップSE
          option_txt = "升级ＳＥ音　　　："
          
          case $game_variables[427]
          
          when 0
             option_txt += "DBZ 強襲！サイヤ人！"
          when 1
            option_txt += "DBZ2 激神フリーザ！！"
          when 2
            option_txt += "DBZ3 烈戦人造人間"
          when 3
            option_txt += "DBZ 超サイヤ伝説"
          else
            option_txt += "DBZ3 烈戦人造人間"
          end
        when @op_win_skn #ウインドウカードスキン
         option_txt = "游戏皮肤　　　　：" 
          if $game_variables[83] == 0
            option_txt += "默认值"
          elsif $game_variables[83] == 1
            option_txt += "DBZ 強襲！サイヤ人！"
          elsif $game_variables[83] == 2
            option_txt += "DBZ2 激神フリーザ！！"
          elsif $game_variables[83] == 3
            option_txt += "DBZ3 烈戦人造人間"
          elsif $game_variables[83] == 4
            option_txt += "DBZ外伝 サイヤ人絶滅計画"
          elsif $game_variables[83] == 5
            option_txt += "DBZ 超サイヤ伝説"
          elsif $game_variables[83] == 6
            option_txt += "DB2 大魔王復活"
          elsif $game_variables[83] == 7
            option_txt += "DB3 悟空伝(フィールド)"
          elsif $game_variables[83] == 8
            option_txt += "DB3 悟空伝(その他)"
          else
          end
        when @op_op_cut #オープニングカット
          option_txt = "跳过ＯＰ　　　　：" 
          if $game_variables[302] == 0
            option_txt += "关闭"
          else
            option_txt += "打开"
          end
        when @op_arasuzi_cut #あらすじカット
          option_txt = "跳过概况　　　　：" 
          if $game_variables[355] == 0
            option_txt += "关闭"
          else
            option_txt += "打开"
          end
        when @op_btl_spd #战斗速度
          option_txt = "战斗速度　　　　：" 
          if $game_variables[303] == 0
            option_txt += "默认值"
          else
            option_txt += "高速化"
          end
        when @op_msg_wait #メッセージウェイト
          option_txt = "消息等待　　　　：" 
          if $game_switches[482] == false
            option_txt += "有效"
          else
            option_txt += "无效"
          end
        when @op_msg_show_fast #メッセージ表示
          option_txt = "消息高速化　　　：" 
          if $game_switches[881] == false
            option_txt += "无效"
          else
            option_txt += "有效"
          end
        when @op_msg_next #メッセージページ送り
          option_txt = "消息翻页　　　　：" 
          if $game_variables[357] == 0
            option_txt += "按下按钮翻页"
          else
            option_txt += "长按按钮也翻页"
          end
        when @op_save_num #セーブデータ数
          option_txt = "存档数　　　　　：" 
          option_txt += $ini_savedata_num.to_s
        when @op_fast_fps #高速化
          option_txt = "游戏高速化　　　：" 
          if $game_switches[492] == false
            option_txt += "使用"
          else
            option_txt += "不使用"
          end
        when @op_card_compo_def #カード合成
          option_txt = "卡片合成　　　　：" 
          if $game_variables[462] == 0
            option_txt += "从配方一览选择"
          else
            option_txt += "从想要制作的卡片选择"
          end
        when @op_card_comporeturn_def #カード
          option_txt = "从配方合成后　　：" 
          if $game_variables[463] == 0
            option_txt += "返回到配方一览画面"
          else
            option_txt += "返回到想要制作的卡片页面"
          end
        when @op_eve_wait #イベントウェイト
          option_txt = "事件等待　　　　：" 
          if $game_switches[882] == false
            option_txt += "有效"
          else
            option_txt += "无效"
          end
        when @op_eve_btl_cut #イベントバトル
          option_txt = "事件战斗　　　　：" 
          if $game_switches[883] == false
            option_txt += "不可跳过"
          else
            option_txt += "可跳过"
          end
        when @op_captozp_bairitu #イベントバトル
          option_txt = "ＣＡＰＺＰ変換量：" 
          case $game_variables[471]
          
          when 0
            option_txt += "1倍"
          when 1
            option_txt += "10倍"
          when 2
            option_txt += "100倍"
          when 3
            option_txt += "1000倍"
          end
        when @op_btl_diff #戦闘難易度
          option_txt = "难易度　　　　　：" 
          if $game_variables[353] == 0
            option_txt += "通常"
          else
            option_txt += $game_variables[353].to_s + "0％以上"
          end
        when @op_op_kabau_cut #かばう演出
          option_txt = "保护发动时　　　：" 
          if $game_switches[884] == false
            option_txt += "显示演出"
          else
            option_txt += "跳过演出"
          end
      end
      
      if option_txt != "" && @option_no[i] != @op_btl_bgm && @option_no[i] != @op_evbtl_bgm && @option_no[i] != @op_meu_bgm && @option_no[i] != @op_btl_ready_bgm && @option_no[i] != @op_evbtl_ready_bgm && @option_no[i] != @op_action_sel_bgm
        #@option_window.contents.draw_text(16,@option_line_height.to_i*i, 640, @option_line_height, option_txt.to_s)
        
        puttxt = 0 #テキスト出力位置調整
        if @put_page == (@put_option_num.size - 1)
          puttxt = tmp_put_option_num - @put_option_num[@put_page] + 1
        elsif @put_page != 0
          puttxt = @put_option_num[@put_page-1] + 1
        end
        @option_window.contents.draw_text(16,@option_line_height.to_i*(i - puttxt), 640, @option_line_height, option_txt.to_s)
      end
      option_txt = ""
      i += 1
    end
  end
  #--------------------------------------------------------------------------
  # ● カーソル表示
  #--------------------------------------------------------------------------
  def output_cursor
    # メニューカーソル表示
    $cursor_blink_count += 1
    picture = Cache.picture("アイコン")
    rect = set_yoko_cursor_blink
    #@option_window.contents.blt(0,@cursor_state*@option_line_height+12,picture,rect)
    
    #@option_window.contents.blt(0,@cursor_state*@option_line_height+2,picture,rect)
    
    if @put_page == 0
      @option_window.contents.blt(0,@cursor_state*@option_line_height+4,picture,rect)
    else
      tmp_cursor_tyouse_y = 0
      for x in 0..(@put_page - 1)
        tmp_cursor_tyouse_y += @put_option_num[x]
      end
      @option_window.contents.blt(0,(@cursor_state-(tmp_cursor_tyouse_y + 1))*@option_line_height+4,picture,rect)
      #@option_window.contents.blt(0,(@cursor_state-(@put_option_num[@put_page-1] + 1))*@option_line_height+4,picture,rect)
    end
  end
  #--------------------------------------------------------------------------
  # ● カーソル移動
  #引数:n (下:2 上:8 右:6 左:4 0:変更なし)
  #--------------------------------------------------------------------------
  def move_cursor n
    # メニューカーソル表示
    case n
    
    when 2
      if @cursor_state != @option_Item_Num - 1 
        @cursor_state += 1
      else
        @cursor_state = 0
      end
    when 8
      if @cursor_state != 0
        @cursor_state -= 1
      else
        @cursor_state = @option_Item_Num - 1
      end
    when 6
      if @option_no[@cursor_state] == @op_btl_bgm
        set_battle_bgm_name
      elsif @option_no[@cursor_state] == @op_evbtl_bgm
        set_battle_bgm_name false,1
      elsif @option_no[@cursor_state] == @op_meu_bgm
        set_menu_bgm_name
      else
        @bgm_name = ""
      end
    when 4
    
      if @option_no[@cursor_state] == @op_btl_bgm
        set_battle_bgm_name
      elsif @option_no[@cursor_state] == @op_evbtl_bgm
        set_battle_bgm_name false,1
      elsif @option_no[@cursor_state] == @op_meu_bgm
        set_menu_bgm_name
      else
        @bgm_name = ""
      end
    
    end
    
    tmp_put_option_num = 0
    
    for x in 0..@put_option_num.size - 1
      tmp_put_option_num += @put_option_num[x]
      if @cursor_state <= tmp_put_option_num
        break
      end
    end
    
    #ページ数をセット
    @put_page = x
    #p @put_page
    
    #if @cursor_state <= @put_option_num[0]
    #  @put_page = 0
      #@s_up_cursor.visible = false
      #@s_down_cursor.visible = true
    #else
    #  @put_page = 1
      #@s_up_cursor.visible = true
      #@s_down_cursor.visible = false
    #end
    
    #カーソル表示
    if @put_page == 0
      #最初のページ
      @s_up_cursor.visible = false
      @s_down_cursor.visible = true
    elsif @put_page == (@put_option_num.size - 1)
      #最後のページ
      @s_up_cursor.visible = true
      @s_down_cursor.visible = false
    else
      #途中のページ
      @s_up_cursor.visible = true
      @s_down_cursor.visible = true
    end
  end
  #--------------------------------------------------------------------------
  # ● オプションメッセージ
  #-------------------------------------------------------------------------- 
  def output_option_message
    
    option_msg = ""
    msg_height = 25
    case @option_no[@cursor_state]

    when @op_btl_scrl #戦闘背景スクロール
      option_msg = "设置战斗时的背景滚动"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
    when @op_btl_mode #戦闘時のデフォルトモード設定
      option_msg = "设置战斗的默认模式"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
    when @op_btl_msg #戦闘メッセージ
      option_msg = "设置经验值等战斗信息的进行"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      #option_msg = "経験値等のメッセージの進行を設定します"
      #@explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg) 
    when @op_btl_bgm #戦闘曲
      option_msg = "设置通常战斗的BGM"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = "※按确定按钮可播放BGM"
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg) 
      option_msg = "※用Y按钮切换随机时的ON、OFF"
      @explanation_window.contents.draw_text(0,msg_height*2, 630, msg_height, option_msg)
    when @op_evbtl_bgm #イベント戦闘曲
      option_msg = "设置事件战斗的BGM"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = "※按确定按钮可播放BGM"
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg) 
      option_msg = "※用Y按钮切换随机时的ON、OFF"
      @explanation_window.contents.draw_text(0,msg_height*2, 630, msg_height, option_msg)
    when @op_btl_ready_bgm #戦闘前曲
      option_msg = "通常战斗前设定BGM"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = "※按确定按钮可播放BGM"
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
      option_msg = "※默认播放战斗BGM"
      @explanation_window.contents.draw_text(0,msg_height*2, 630, msg_height, option_msg) 
    when @op_evbtl_ready_bgm #戦闘前曲
      option_msg = "设置事件战斗前BGM"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = "※按确定按钮可播放BGM"
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
      option_msg = "※默认播放战斗BGM"
      @explanation_window.contents.draw_text(0,msg_height*2, 630, msg_height, option_msg) 
    when @op_btl_end_bgm #戦闘終了曲
      option_msg = "设置战斗结束的BGM"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = "※按确定按钮可播放BGM"
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
      option_msg = "※默认继续播放战斗BGM"
      @explanation_window.contents.draw_text(0,msg_height*2, 630, msg_height, option_msg) 
      #option_msg = "※Ｙボタンでランダム時のＯＮ、ＯＦＦを切り替えます。"
      #@explanation_window.contents.draw_text(0,msg_height*2, 630, msg_height, option_msg) 
    when @op_meu_bgm #メニュー曲
      option_msg = "设置菜单BGM"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = "※按确定按钮可播放BGM"
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg) 
      option_msg = "※用Y按钮切换随机时的ON、OFF"
      @explanation_window.contents.draw_text(0,msg_height*2, 630, msg_height, option_msg)
    when @op_action_sel_bgm #メニュー曲
      option_msg = "设置行动选择画面的BGM"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = "※按确定按钮可播放BGM"
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg) 
    when @op_btl_enc #エンカウント頻度
      option_msg = "设置遇敌频率"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
    when @op_btl_enc_se #エンカウント音頻度
      option_msg = "设置遇敌音"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = "※按确定按钮可播放BGM"
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg) 
    when @op_btl_dmg #ダメージ表示
      option_msg = "设置战斗伤害的显示位置"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
    when @op_btl_skl #発動スキル表示
      option_msg = "设置战斗时技能发动的显示条件"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)      
    when @op_btl_skl_slide #発動スキル表示方法
      option_msg = "设置战斗时技能发动的显示方法"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)      
    when @op_btl_kanashibari #かなしばり回数表示
      option_msg = "设置战斗时束缚次数的显示方法"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)      
    when @op_scon_priority #Sコンボ発動優先度
      option_msg = "设置组合技的发动优先级"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)      
      #option_msg = "※デフォルトはゲーム側で設定された順"
      #@explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg) 
      
    when @op_walk_mode #歩行モード(Z1_2-オリジナル)
      option_msg = "设置步行模式。"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = "※默认值与DBZ3烈战人造人的移动相同"
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
    when @op_btl_explode #戦闘爆発変化
      option_msg = "设置战斗必杀技的爆炸变化"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = "※关闭时每个技能都固定、开启了会根据伤害的比例进行变化"
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
    when @op_levelupse
      option_msg = "设置角色升级时的SE音"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = "※按确定按钮可播放ＳＥ"
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
      #option_msg = "※画面を切り替えると設定が反映されます。"
      #@explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
    when @op_win_skn
      option_msg = "设置游戏的皮肤"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      #option_msg = "※画面を切り替えると設定が反映されます。"
      #@explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
    when @op_op_cut
      option_msg = "开启或关闭游戏启动的OP"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
    when @op_arasuzi_cut 
      option_msg = "开启或关闭加载存档时的概况显示"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
    when @op_btl_spd
      option_msg = "设置战斗时没有按下确定键的游戏速度"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = "※事件战斗时该设置无效"
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
    when @op_msg_wait #メッセージウェイト
      option_msg = "事件信息的等待设置"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = ""
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
    when @op_msg_show_fast #メッセージ常時高速化
      option_msg = "设置事件时的信息显示高速化"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = "※无论设置如何，R+确定、取消都可以加快速度"
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)      
    when @op_msg_next #メッセージページ送り
      option_msg = "事件和战斗时的翻页设置"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = "※无论设置如何，R+确定、取消都可以翻页"
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
      option_msg = "※只作用于战斗中的[战斗信息：指南]"
      @explanation_window.contents.draw_text(0,msg_height*2, 630, msg_height, option_msg)
    when @op_save_num #セーブデータ数
      option_msg = "设置存档数量"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = "※最小：３个　最大：２５５个"
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
    when @op_fast_fps #高速化
      option_msg = "设置是否使用游戏高速化"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = "※【CTRL】、【Z】键按下时的高速化设置"
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
    when @op_card_compo_def #カード合成
      option_msg = "设置卡片合成配方时的默认显示画面"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      #option_msg = "※【CTRL】キー【Z】ボタンを押したときの高速化の設定です"
      #@explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
    when @op_card_comporeturn_def #カード合成
      option_msg = "设置从配方中[想制作的卡]合成之后返回的画面"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      #option_msg = "※【CTRL】キー【Z】ボタンを押したときの高速化の設定です"
      #@explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
    when @op_eve_wait #イベントウェイト
      option_msg = "事件时的等待设置"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = ""
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
    when @op_eve_btl_cut #イベントウェイト
      option_msg = "设置是否能跳过战斗事件"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = ""
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
    when @op_captozp_bairitu #重力装置カードの上昇量
      option_msg = "设置使用重力装置卡时按上下按钮时的转换量"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = ""
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
    when @op_btl_diff #戦闘難易度
      option_msg = "设定战斗的难度"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      option_msg = "※敌人的能力和经验值会根据设定值上升"
      @explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
      option_msg = "※最大值可根据周目数提升"
      @explanation_window.contents.draw_text(0,msg_height*2, 630, msg_height, option_msg)
    when @op_meu_skl_put #スキル一覧表示
      option_msg = "设置能力画面显示的技能一览表"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      #option_msg = "※本機能は"
      #@explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
    when @op_op_kabau_cut #かばう演出をカットするか
      option_msg = "设定战斗保护技能有无演出"
      @explanation_window.contents.draw_text(0,msg_height*0, 630, msg_height, option_msg)
      #option_msg = "※「カットする」を選択するとかばうを発動しても"
      #@explanation_window.contents.draw_text(0,msg_height*1, 630, msg_height, option_msg)
    
    end
      
  end
  #--------------------------------------------------------------------------
  # ● メニュー再生
  #--------------------------------------------------------------------------    
  def set_bgm
      set_menu_bgm_name true
      #Audio.bgm_play("Audio/BGM/" + $option_menu_bgm_name)
      if $option_menu_bgm_name.include?("_user") == false
        Audio.bgm_play("Audio/BGM/" + $option_menu_bgm_name)    # 効果音を再生する
      else
        Audio.bgm_play("Audio/MYBGM/" + $option_menu_bgm_name)    # 効果音を再生する
      end
  end

  #--------------------------------------------------------------------------
  # ● スプライト開放
  #--------------------------------------------------------------------------
  def dispose_sprite
    @s_up_cursor.bitmap = nil
    @s_down_cursor.bitmap = nil
    @s_up_cursor = nil
    @s_down_cursor = nil
  end
  
  #--------------------------------------------------------------------------
  # ● 上下カーソルの設定
  #-------------------------------------------------------------------------- 
  def set_up_down_cursor
   picture = Cache.picture("アイコン")
    
    #Sコンボ上カーソル
    # スプライトのビットマップに画像を設定
    @s_up_cursor.bitmap = Cache.picture("アイコン")
    @s_up_cursor.src_rect = Rect.new(16*5, 0, 16, 16)
    @s_up_cursor.x = Explanation_win_sizex/2 - 8
    @s_up_cursor.y = Explanation_win_sizey+16#Status_win_sizey+16+32
    @s_up_cursor.z = 255
    @s_up_cursor.angle = 91
    @s_up_cursor.visible = false
    
    #Sコンボ下カーソル
    # スプライトのビットマップに画像を設定
    @s_down_cursor.bitmap = Cache.picture("アイコン")
    @s_down_cursor.src_rect = Rect.new(16*5, 0, 16, 16)
    @s_down_cursor.x = Explanation_win_sizex/2 + 8
    @s_down_cursor.y = 480-16
    @s_down_cursor.z = 255
    @s_down_cursor.angle = 269
    @s_down_cursor.visible = true

  end
  
end