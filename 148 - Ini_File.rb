#==============================================================================
# ■ Ini_File
#------------------------------------------------------------------------------
# 　iniファイルからのデータ読み出しを行うクラスです。
#   動作にはEasyConv(ＨＰにて別途配布)が必要です。
#==============================================================================

class Ini_File
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(filename)
    @filename = filename

  # ファイル存在チェック(見つからない場合は問答無用で終了する)
    unless FileTest.exist?(@filename)
      p sprintf("error/Ini_File -- iniファイルが見つかりません。")
      exit
    end
    
  # ファイルパスの設定(APIで使用)
    @filepath = File.expand_path("./") + "/" + @filename
   
  # ファイルパスをS-JISに変換
    if $windows_env
      @filepath = EasyConv::u2s(@filepath)
    @filepath.gsub!(/(\/)/) { "\\" }
    end
  end
  
  def get_prof(section, key, default_value, buffer, buffer_size, filename)
    return default_value unless File.exist?(filename)
    current_section = nil
    result = default_value
    
    File.foreach(filename) do |line|
      line.strip!
      next if line.empty? || line.start_with?(';')
      if line =~ /^\[(.+)\]$/
        current_section = Regexp.last_match(1)
      elsif current_section == section && line =~ /^([^=]+)=(.*)$/
        ini_key, ini_value = Regexp.last_match(1).strip, Regexp.last_match(2).strip
        if ini_key == key
          result = ini_value
          break
        end
      end
    end

    # 确保返回的字符串不超过缓冲区大小
    result = result[0, buffer_size - 1]
    buffer.replace(result)
  end
  
  def set_prof(section, key, value, filename)
    # 读取现有的文件内容
    ini_data = {}
    current_section = nil

    if File.exist?(filename)
      File.foreach(filename) do |line|
        line.strip!
        if line =~ /^\[(.+)\]$/
          current_section = Regexp.last_match(1)
          ini_data[current_section] ||= {}
        elsif current_section && line =~ /^([^=]+)=(.*)$/
          ini_key, ini_value = Regexp.last_match(1).strip, Regexp.last_match(2).strip
          ini_data[current_section][ini_key] = ini_value
        end
      end
    end

    # 更新或添加新的值
    ini_data[section] ||= {}
    ini_data[section][key] = value

    # 写回文件
    File.open(filename, 'w') do |file|
      ini_data.each do |sect, keys|
        file.puts "[#{sect}]"
        keys.each do |k, v|
          file.puts "#{k}=#{v}"
        end
        file.puts ""
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # ● データの取得
  #--------------------------------------------------------------------------
  # section：セクション名
  # key    ：キー名
  # 返り値 ：キーの値を返す。データが存在しない場合は""。
  #--------------------------------------------------------------------------
  def get_profile(section,key)
    buffer = "\0" * 256
    if $windows_env
      # API宣言
      get_prof = Win32API.new('kernel32', 'GetPrivateProfileStringA', %w(p p p p l p), 'l')
      # section,keyをSHIFT-JISに変換する
      section = EasyConv::u2s(section)
      key     = EasyConv::u2s(key)
      # APIを使用してキーを取得
      get_prof.call(section, key, "", buffer, 255, @filepath)
    else 
      get_prof(section, key, "", buffer, 255, @filepath)
    end 
  
  # バッファ内データをUTF-8に変換
    buffer = EasyConv::s2u(buffer)
    buffer.delete!("\0")
  
  # ""の場合はnilを返す
    buffer == "" ? buffer = nil : nil
    return buffer
  end

  
  #--------------------------------------------------------------------------
  # ● データの書出
  #--------------------------------------------------------------------------
  # section：セクション名
  # key    ：キー名
  # value  ：キーの値
  # 返り値 ：書き込み処理の成否
  #--------------------------------------------------------------------------
  def write_profile(section,key,value)
    if $windows_env
      # API宣言
      set_prof = Win32API.new('kernel32', 'WritePrivateProfileStringA', %w(p p p p), 'l')
      #section,key,valueをSHIFT-JISに変換する
      section = EasyConv::u2s(section)
      key     = EasyConv::u2s(key)
      value   = EasyConv::u2s(value)
      # APIを使用してキーを書き込み
      return set_prof.call(section, key, value, @filepath)
    else
      return set_prof(section, key, value, @filepath)
    end
  end
end
