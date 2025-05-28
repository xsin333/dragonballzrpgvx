$windows_env = File::ALT_SEPARATOR == "\\"

class Fixnum
  def prec_f
    self.to_f
  end
  
  def prec_i
    self.to_i
  end
  
  def limit(min, max)
    if self < min
      return min
    elsif self > max
      return max
    else
      return self
    end
  end
end

class Float
  def prec_f
    self.to_f
  end
  def prec_i
    self.to_i
  end
end

class Bitmap
  def set_text_content(text)
    @text_content = text
  end
  
  def change_text_color(red, green, blue)
    if @text_content != nil
      output_mozi_joiplay(@text_content, red, green, blue)
    end
  end
end

def output_mozi_joiplay(mozi, color_r=0, color_g=0, color_b=0)
  mozi = convert_special_characters mozi
  mozi_num = mozi.split(//u).size
  #p mozi,mozi_num
  $tec_mozi=Bitmap.new(24*(mozi_num)+24, 24)
  $tec_mozi.set_text_content(mozi)
  listnoy = 3
  
  for x in 0..mozi_num-1
    itimozi = mozi.split(//)[x,1].join(" ")
    case itimozi #mozi.split(//)[x,1]
    when "0"
      itimozi = "０"
    when "1"
      itimozi = "１"
    when "2"
      itimozi = "２"
    when "3"
      itimozi = "３"
    when "4"
      itimozi = "４"
    when "5"
      itimozi = "５"
    when "6"
      itimozi = "６"
    when "7"
      itimozi = "７"
    when "8"
      itimozi = "８"
    when "9"
      itimozi = "９"
    when "A"
      itimozi = "Ａ"
    when "B"
      itimozi = "Ｂ"
    when "C"
      itimozi = "Ｃ"
    when "D"
      itimozi = "Ｄ"
    when "E"
      itimozi = "Ｅ"
    when "F"
      itimozi = "Ｆ"
    when "G"
      itimozi = "Ｇ"
    when "H"
      itimozi = "Ｈ"
    when "I"
      itimozi = "Ｉ"
    when "J"
      itimozi = "Ｊ"
    when "K"
      itimozi = "Ｋ"
    when "L"
      itimozi = "Ｌ"
    when "M"
      itimozi = "Ｍ"
    when "N"
      itimozi = "Ｎ"
    when "O"
      itimozi = "Ｏ"
    when "P"
      itimozi = "Ｐ"
    when "Q"
      itimozi = "Ｑ"
    when "R"
      itimozi = "Ｒ"
    when "S"
      itimozi = "Ｓ"
    when "T"
      itimozi = "Ｔ"
    when "U"
      itimozi = "Ｕ"
    when "V"
      itimozi = "Ｖ"
    when "W"
      itimozi = "Ｗ"
    when "X"
      itimozi = "Ｘ"
    when "Y"
      itimozi = "Ｙ"
    when "Z"
      itimozi = "Ｚ"
    when "l"#(LV)
      itimozi = "Lv"
    when "x" #小さい英語
      itimozi = "ｘ"
    when "("
      itimozi = "（"
    when ")"
      itimozi = "）"
    when "!"
      itimozi = "！"
    when "?"
      itimozi = "？"
    when "-"
      itimozi = "－"
    end
    $tec_mozi.font.color.set(color_r,color_g,color_b)
    $tec_mozi.font.size = 24
    $tec_mozi.draw_text(16 * x, -1, 32, 32, itimozi)
  end 
end

def set_bonus_rate
  if $game_switches[860] == true
    ini = Ini_File.new("Game.ini")
    $exp_rate = (ini.get_profile("Game", "Exp_rate")).to_i.limit(1, 100)
    $cap_rate = (ini.get_profile("Game", "Cap_rate")).to_i.limit(1, 100)
    $sp_rate = (ini.get_profile("Game", "Sp_rate")).to_i.limit(1, 100)
  else
    $exp_rate = 1
    $cap_rate = 1
    $sp_rate = 1
  end
end