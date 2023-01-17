﻿-- Addon: WoWinArabic_Quests (wersja: 10.00) 2023.01.13
-- الوصف: تعرض الوظيفة الإضافية المهام المترجمة إلى اللغة العربية
-- Opis: AddOn wyświetla przetłumaczone questy w języku arabskim.
-- Autor: Platine  (e-mail: platine.wow@gmail.com)
-- Addon project page: https://wowpopolsku.pl

-- Zmienne lokalne
local QTR_version = GetAddOnMetadata("WoWinArabic_Quests", "Version");
local QTR_limit1 = 38;        -- limit znaków w linii opisującej zadanie w Map&Quest Log
local QTR_limit2 = 28;        -- limit znaków w linii opisującej zadanie w oknie rozmowy z NPC
local QTR_limit3 = 18;        -- limit znaków w linii opisującej potworka w QuestNPCModelText
local QTR_onDebug = false;      
local QTR_name = UnitName("player");
local QTR_class= UnitClass("player");
local QTR_race = UnitRace("player");
local QTR_sex = UnitSex("player");     -- 1:neutral,  2:męski,  3:żeński
local QTR_waitTable = {};
local QTR_waitFrame = nil;
local QTR_MessOrig = {
      details    = "Description", 
      objectives = "Quest Objectives", 
      rewards    = "Rewards", 
      itemchoose0= "You will receive:",
      itemchoose1= "You will be able to choose one of these rewards:", 
      itemchoose2= "Choose one of these rewards:", 
      itemchoose3= "You receiving the reward:",
      itemreceiv0= "You will receive:",
      itemreceiv1= "You will also receive:", 
      itemreceiv2= "You receiving the reward:", 
      itemreceiv3= "You also receiving the reward:",
      learnspell = "Learn Spell:", 
      reqmoney   = "Required Money:", 
      reqitems   = "Required items:", 
      experience = "Experience:", 
      currquests = "Current Quests", 
      avaiquests = "Available Quests", 
      reward_aura      = "The following will be cast on you:", 
      reward_spell     = "You will learn the following:", 
      reward_companion = "You will gain these Companions:", 
      reward_follower  = "You will gain these followers:", 
      reward_reputation= "Reputation awards:", 
      reward_title     = "You shall be granted the title:", 
      reward_tradeskill= "You will learn how to create:", 
      reward_unlock    = "You will unlock access to the following:", 
      reward_bonus     = "Completing this quest while in Party Sync may reward:", 
      };
local QTR_quest_ID = 0;      
local QTR_quest_EN = { };      
local QTR_quest_LG = { };      
      QTR_quest_EN[0] = { };
      QTR_quest_LG[0] = { };
local last_time = GetTime();
local last_text = 0;
local curr_trans = "1";
local curr_goss = "X";
local curr_hash = 0;
local QTR_first_show = 0;
local QTR_first_show2 = 0;
local QTR_first_voice = 0;
local QTR_first_gs_show = 0;
local QTR_first_gs_voice = 0;
local QTR_ModelTextHash = 0;
local QTR_ModelText_EN = ""; 
local QTR_ModelText_PL = ""; 
local aktShow = 0;      -- liczba aktualnie przypisanych zdarzeń OnShow do NPE_PointerFrame
local tutShow = 0;      -- znacznik przypisania skryptu od wyświetlenia okienka tutoriału
local Original_Font1 = "Fonts\\MORPHEUS.ttf";
local Original_Font2 = "Fonts\\FRIZQT__.ttf";
local QTR_FrameOnLine, QTR_FrameOnLineButton, QTR_FrameOnLineHash;
local Tut_ID = 0;
local Tut_race = string.gsub(strupper(QTR_race)," ","");
local Tut_class= string.gsub(strupper(QTR_class)," ","");
if (Tut_class == "DEATHKNIGHT") then
   Tut_race = "DEATHKNIGHT";
end
local quest_numReward = {};       -- liczba dostępnych nagród do questu
local time_ver = GetTime() - 15*60;

local p_race = {
      ["Blood Elf"] = { M1="قزم الدم", D1="krwawego elfa", B1="krwawego elfa", M2="قزم الدم", D2="krwawej elfki", B2="krwawą elfkę" }, 
      ["Dark Iron Dwarf"] = { M1="القزم الحديدي المظلم", D1="krasnoluda Ciemnego Żelaza", B1="القزم الحديدي المظلم", M2="Krasnoludzica Ciemnego Żelaza", D2="krasnoludzicy Ciemnego Żelaza", B2="krasnoludzicę Ciemnego Żelaza" },
      ["Dracthyr"] = { M1="Dracthyr", D1="draktyra", B1="draktyra", M2="Dracthyr", D2="draktyrki", B2="draktyrkę" },
      ["Draenei"] = { M1="درايني", D1="draeneia", B1="draeneia", M2="درايني", D2="draeneiki", B2="draeneikę" },
      ["Dwarf"] = { M1="قزم", D1="krasnoluda", B1="krasnoluda", M2="قزم", D2="krasnoludzicy", B2="krasnoludzicę" },
      ["Gnome"] = { M1="جنوم", D1="gnoma", B1="gnoma", M2="جنوم", D2="gnomki", B2="gnomkę" },
      ["Goblin"] = { M1="عفريت", D1="goblina", B1="goblina", M2="عفريت", D2="goblinki", B2="goblinkę" },
      ["Highmountain Tauren"] = { M1="هايمونتين تورين", D1="taurena z Wysokiej Góry", B1="taurena z Wysokiej Góry", M2="هايمونتين تورين", D2="taurenki z Wysokiej Góry", B2="taurenkę z Wysokiej Góry" },
      ["Human"] = { M1="بشري", D1="człowieka", B1="człowieka", M2="بشري", D2="człowieka", B2="człowieka" },
      ["Kul Tiran"] = { M1="كول تيران", D1="Kul Tirana", B1="Kul Tirana", M2="كول تيران", D2="Kul Tiranki", B2="Kul Tirankę" },
      ["Lightforged Draenei"] = { M1="Lightforged Draenei", D1="świetlistego draeneia", B1="świetlistego draeneia", M2="Lightforged Draenei", D2="świetlistej draeneiki", B2="świetlistą draeneikę" },
      ["Mag'har Orc"] = { M1="Mag'har Orc", D1="orka z Mag'har", B1="orka z Mag'har", M2="Mag'har Orc", D2="orczycy z Mag'har", B2="orczycę z Mag'har" },
      ["Mechagnome"] = { M1="Mechagnome", D1="mechagnoma", B1="mechagnoma", M2="Mechagnome", D2="mechagnomki", B2="mechagnomkę" },
      ["Nightborne"] = { M1="منقول ليلا", D1="dziecięcia nocy", B1="dziecię nocy", M2="منقول ليلا", D2="dziecięcia nocy", B2="dziecię nocy" },
      ["Night Elf"] = { M1="قزم الليل", D1="nocnego elfa", B1="nocnego elfa", M2="قزم الليل", D2="nocnej elfki", B2="nocną elfkę" },
      ["Orc"] = { M1="مسخ", D1="orka", B1="orka", M2="مسخ", D2="orczycy", B2="orczycę" },
      ["Pandaren"] = { M1="باندارين", D1="pandarena", B1="pandarena", M2="باندارين", D2="pandarenki", B2="pandarenkę" },
      ["Tauren"] = { M1="تورين", D1="taurena", B1="taurena", M2="تورين", D2="taurenki", B2="taurenkę" },
      ["Troll"] = { M1="القزم", D1="trolla", B1="trolla", M2="القزم", D2="trollicy", B2="trollicę" },
      ["Undead"] = { M1="ميت حي", D1="nieumarłego", B1="nieumarłego", M2="ميت حي", D2="nieumarłej", B2="nieumarłą" },
      ["Void Elf"] = { M1="باطل عفريت", D1="elfa Pustki", B1="elfa Pustki", M2="باطل عفريت", D2="elfki Pustki", B2="elfkę Pustki" },
      ["Vulpera"] = { M1="فولبيرا", D1="lisołaka", B1="lisołaka", M2="فولبيرا", D2="lisołaczki", B2="lisołaczkę" },
      ["Worgen"] = { M1="وورجين", D1="worgena", B1="worgena", M2="وورجين", D2="worgenki", B2="worgenkę" },
      ["Zandalari Troll"] = { M1="زاندالاري ترول", D1="trolla Zandalari", B1="trolla Zandalari", M2="زاندالاري ترول", D2="trollicy Zandalari", B2="trollicę Zandalari" }, }
local p_class = {
      ["Death Knight"] = { M1="فارس الموت", D1="rycerz śmierci", B1="rycerza śmierci", M2="فارس الموت", D2="rycerz śmierci", B2="rycerza śmierci" },
      ["Demon Hunter"] = { M1="صائد الشيطان", D1="łowcy demonów", B1="łowcę demonów", M2="صائد الشيطان", D2="łowczyni demonów", B2="łowczynię demonów" },
      ["Druid"] = { M1="الكاهن", D1="druida", B1="druida", M2="الكاهن", D2="druidki", B2="druidkę" },
      ["Evoker"] = { M1="إيفوكر", D1="przywoływacza", B1="przywoływacza", M2="إيفوكر", D2="przywoływaczki", B2="przywoływaczkę" },
      ["Hunter"] = { M1="صياد", D1="łowcy", B1="łowcę", M2="صياد", D2="łowczyni", B2="łowczynię" },
      ["Mage"] = { M1="بركه", D1="maga", B1="maga", M2="بركه", D2="magini", B2="maginię" },
      ["Monk"] = { M1="راهب", D1="mnicha", B1="mnicha", M2="راهب", D2="mniszki", B2="mniszkę" },
      ["Paladin"] = { M1="بالادين", D1="paladyna", B1="paladyna", M2="بالادين", D2="paladynki", B2="paladynkę" },
      ["Priest"] = { M1="كاهن", D1="kapłana", B1="kapłana", M2="كاهن", D2="kapłanki", B2="kapłankę" },
      ["Rogue"] = { M1="محتال", D1="łotrzyka", B1="łotrzyka", M2="محتال", D2="łotrzycy", B2="łotrzycę" },
      ["Shaman"] = { M1="شامان", D1="szamana", B1="szamana", M2="شامان", D2="szamanki", B2="szamankę" },
      ["Warlock"] = { M1="الساحر", D1="czarnoksiężnika", B1="czarnoksiężnika", M2="الساحر", D2="czarownicy", B2="czarownicę" },
      ["Warrior"] = { M1="محارب", D1="wojownika", B1="wojownika", M2="محارب", D2="wojowniczki", B2="wojowniczkę" }, }
if (p_race[QTR_race]) then      
   player_race = { M1=p_race[QTR_race].M1, D1=p_race[QTR_race].D1, B1=p_race[QTR_race].B1, M2=p_race[QTR_race].M2, D2=p_race[QTR_race].D2, B2=p_race[QTR_race].B2 };
else   
   player_race = { M1=QTR_race, D1=QTR_race, B1=QTR_race, M2=QTR_race, D2=QTR_race, B2=QTR_race };
   print ("|cff55ff00QTR - new race: "..QTR_race);
end
if (p_class[QTR_class]) then
   player_class = { M1=p_class[QTR_class].M1, D1=p_class[QTR_class].D1, B1=p_class[QTR_class].B1, M2=p_class[QTR_class].M2, D2=p_class[QTR_class].D2, B2=p_class[QTR_class].B2 };
else
   player_class = { M1=QTR_class, D1=QTR_class, B1=QTR_class, M2=QTR_class, D2=QTR_class, B2=QTR_class };
   print ("|cff55ff00QTR - new class: "..QTR_class);
end



local function StringHash(text)           -- funkcja tworząca Hash (32-bitowa liczba) podanego tekstu
  local counter = 1;
  local pomoc = 0;
  local dlug = string.len(text);
  for i = 1, dlug, 3 do 
    counter = math.fmod(counter*8161, 4294967279);  -- 2^32 - 17: Prime!
    pomoc = (string.byte(text,i)*16776193);
    counter = counter + pomoc;
    pomoc = ((string.byte(text,i+1) or (dlug-i+256))*8372226);
    counter = counter + pomoc;
    pomoc = ((string.byte(text,i+2) or (dlug-i+256))*3932164);
    counter = counter + pomoc;
  end
  return math.fmod(counter, 4294967291) -- 2^32 - 5: Prime (and different from the prime in the loop)
end


-- returns the number of bytes used by the UTF-8 character at byte in s
local function QTR_utf8charbytes(s, i)
	-- argument defaults
	i = i or 1

	-- argument checking
	if type(s) ~= "string" then
		error("bad argument #1 to 'utf8charbytes' (string expected, got ".. type(s).. ")")
	end
	if type(i) ~= "number" then
		error("bad argument #2 to 'utf8charbytes' (number expected, got ".. type(i).. ")")
	end

	local c = strbyte(s, i)

	-- determine bytes needed for character, based on RFC 3629
	-- validate byte 1
	if c > 0 and c <= 127 then
		-- UTF8-1
		return 1

	elseif c >= 194 and c <= 223 then
		-- UTF8-2
		local c2 = strbyte(s, i + 1)

		if not c2 then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if c2 < 128 or c2 > 191 then
			error("Invalid UTF-8 character")
		end

		return 2

	elseif c >= 224 and c <= 239 then
		-- UTF8-3
		local c2 = strbyte(s, i + 1)
		local c3 = strbyte(s, i + 2)

		if not c2 or not c3 then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if c == 224 and (c2 < 160 or c2 > 191) then
			error("Invalid UTF-8 character")
		elseif c == 237 and (c2 < 128 or c2 > 159) then
			error("Invalid UTF-8 character")
		elseif c2 < 128 or c2 > 191 then
			error("Invalid UTF-8 character")
		end

		-- validate byte 3
		if c3 < 128 or c3 > 191 then
			error("Invalid UTF-8 character")
		end

		return 3

	elseif c >= 240 and c <= 244 then
		-- UTF8-4
		local c2 = strbyte(s, i + 1)
		local c3 = strbyte(s, i + 2)
		local c4 = strbyte(s, i + 3)

		if not c2 or not c3 or not c4 then
			error("UTF-8 string terminated early")
		end

		-- validate byte 2
		if c == 240 and (c2 < 144 or c2 > 191) then
			error("Invalid UTF-8 character")
		elseif c == 244 and (c2 < 128 or c2 > 143) then
			error("Invalid UTF-8 character")
		elseif c2 < 128 or c2 > 191 then
			error("Invalid UTF-8 character")
		end

		-- validate byte 3
		if c3 < 128 or c3 > 191 then
			error("Invalid UTF-8 character")
		end

		-- validate byte 4
		if c4 < 128 or c4 > 191 then
			error("Invalid UTF-8 character")
		end

		return 4

	else
		error("Invalid UTF-8 character")
	end
end


-- Odwraca kolejność liter w wierszach po 38 lub 28 znaków
local function QTR_Reverse(arabic_string, limit_znakow)
	local bytes = strlen(arabic_string);
	local pos = 1;
	local charbytes;
	local newstr = "";
   local retstr = "";
   local counter = 0;
   local char1;

	while pos <= bytes do
		c = strbyte(arabic_string, pos);                      -- odczytaj znak
		charbytes = QTR_utf8charbytes(arabic_string, pos);    -- liczna bajtów znaku
		newstr = newstr .. strsub(arabic_string, pos, pos + charbytes - 1);
		pos = pos + charbytes;
      
      counter = counter + 1;
      char1 = strsub(arabic_string, pos, pos);
      if ((char1 == "#") or ((char1 == " ") and (counter>limit_znakow))) then
         newstr = string.gsub(newstr, "#", "");
         retstr = retstr .. string.utf8reverse(newstr) .. "\n";
         newstr = "";
         counter = 0;
      end
	end
   retstr = retstr .. string.utf8reverse(newstr);

	return retstr;

end 


-- Zmienne programowe zapisane na stałe na komputerze
function QTR_CheckVars()
  if (not QTR_PS) then
     QTR_PS = {};
  end
   -- zapis wersji patcha Wow'a
  QTR_PS["patch"] = GetBuildInfo();    -- zapisz za każdym razem, bo może masz nową wersję gry
  
  -- inicjalizacja: tłumaczenia włączone
  if (not QTR_PS["active"]) then
     QTR_PS["active"] = "1";
  end
  -- inicjalizacja: tłumaczenie tytułu questu włączone
  if (not QTR_PS["transtitle"] ) then
     QTR_PS["transtitle"] = "0";   
  end
  if (not QTR_PS["transfixed"] ) then
     QTR_PS["transfixed"] = "1";   
  end
  if (not QTR_PS["ownname"] ) then
     QTR_PS["ownname"] = "1";   
  end
  if (not QTR_PS["ownname_obj"] ) then
     QTR_PS["ownname_obj"] = "1";   
  end
  -- zmienna specjalna dostępności funkcji GetQuestID 
  if ( QTR_PS["isGetQuestID"] ) then
     isGetQuestID=QTR_PS["isGetQuestID"];
  end;
end


-- Sprawdza dostępność funkcji specjalnej Wow'a: GetQuestID()
function DetectEmuServer()
  QTR_PS["isGetQuestID"]="0";
  isGetQuestID="0";
  -- funkcja GetQuestID() występuje tylko na serwerach Blizzarda
  if ( GetQuestID() ) then
     QTR_PS["isGetQuestID"]="1";
     isGetQuestID="1";
  end
end


-- Obsługa komend slash
function QTR_SlashCommand(msg)
   if (msg=="on" or msg=="ON" or msg=="1") then
      if (QTR_PS["active"]=="1") then
         print ("QTR - translations are enabled.");
      else
         print ("|cffffff00QTR - I turn on quest translations.");
         QTR_PS["active"] = "1";
         QTR_ToggleButton0:Enable();
         QTR_ToggleButton1:Enable();
         QTR_ToggleButton2:Enable();
         QTR_Translate_On(1);
      end
   elseif (msg=="off" or msg=="OFF" or msg=="0") then
      if (QTR_PS["active"]=="0") then
         print ("QTR - translations are disabled.");
      else
         print ("|cffffff00QTR - I turn off quest translations.");
         QTR_PS["active"] = "0";
         QTR_ToggleButton0:Disable();
         QTR_ToggleButton1:Disable();
         QTR_ToggleButton2:Disable();
         QTR_Translate_Off(1);
      end
   elseif (msg=="title on" or msg=="TITLE ON" or msg=="title 1") then
      if (QTR_PS["transtilte"]=="1") then
         print ("QTR - translation of quest titles is enabled.");
      else
         print ("|cffffff00QTR - I turn on quest title translations.");
         QTR_PS["transtitle"] = "1";
         QuestInfoTitleHeader:SetFont(QTR_Font1, 18);
      end
   elseif (msg=="title off" or msg=="TITLE OFF" or msg=="title 0") then
      if (QTR_PS["transtilte"]=="0") then
         print ("QTR - translation of quest titles is disabled.");
      else
         print ("|cffffff00QTR - I turn off quest title translations.");
         QTR_PS["transtitle"] = "0";
         QuestInfoTitleHeader:SetFont(Original_Font1, 18);
      end
   elseif (msg=="title" or msg=="TITLE") then
      if (QTR_PS["transtilte"]=="1") then
         print ("QTR - translation of quest titles is enabled.");
      else
         print ("QTR - translation of quest titles is disabled.");
      end
   elseif (msg=="") then
      Settings.OpenToCategory("WoWinArabic-Quests");
   else
      print ("QTR - addon's quick commands:");
      print ("      /qtr on|1  - turn on the quest transtalions");
      print ("      /qtr off|0 - turn off the quest translations");
      print ("      /qtr title on|1  - turn on the quest title translations");
      print ("      /qtr title off|0 - turn off the quest title translations");
   end
end


function QTR_SetCheckButtonState()
  QTRCheckButton0:SetValue(QTR_PS["active"]=="1");
  QTRCheckButton3:SetValue(QTR_PS["transtitle"]=="1");
  QTRCheckButton5:SetValue(QTR_PS["transfixed"]=="1");
--  QTRCheckButtonOwnName:SetValue(QTR_PS["ownname"]=="1");
--  QTRCheckButtonOwnName2:SetValue(QTR_PS["ownname_obj"]=="1");
end


function QTR_BlizzardOptions()
  -- Create main frame for information text
  local QTROptions = CreateFrame("FRAME", "WoWinArabic_Quests_Options");
  QTROptions.name = "WoWinArabic-Quests";
  QTROptions.refresh = function (self) QTR_SetCheckButtonState() end;
  InterfaceOptions_AddCategory(QTROptions);

  local QTROptionsHeader = QTROptions:CreateFontString(nil, "ARTWORK");
  QTROptionsHeader:SetFontObject(GameFontNormalLarge);
  QTROptionsHeader:SetJustifyH("LEFT"); 
  QTROptionsHeader:SetJustifyV("TOP");
  QTROptionsHeader:ClearAllPoints();
  QTROptionsHeader:SetPoint("TOPLEFT", 16, -16);
  QTROptionsHeader:SetText("WoWinArabic-Quests, ver. "..QTR_version.." ("..QTR_base..") by Platine © 2023");

  local QTRDateOfBase = QTROptions:CreateFontString(nil, "ARTWORK");
  QTRDateOfBase:SetFontObject(GameFontNormalLarge);
  QTRDateOfBase:SetJustifyH("LEFT"); 
  QTRDateOfBase:SetJustifyV("TOP");
  QTRDateOfBase:ClearAllPoints();
  QTRDateOfBase:SetPoint("TOPRIGHT", QTROptionsHeader, "TOPRIGHT", 0, -22);
  QTRDateOfBase:SetText("Date of translation base: "..QTR_date);
  QTRDateOfBase:SetFont(QTR_Font2, 16);

  local QTRCheckButton0 = CreateFrame("CheckButton", "QTRCheckButton0", QTROptions, "SettingsCheckBoxControlTemplate");
  QTRCheckButton0.CheckBox:SetScript("OnClick", function(self) if (QTR_PS["active"]=="1") then QTR_PS["active"]="0" else QTR_PS["active"]="1" end; end);
  QTRCheckButton0.CheckBox:SetPoint("TOPLEFT", QTRDateOfBase, "BOTTOMLEFT", 300, -50);    -- pozycja przycisku CheckBox
  QTRCheckButton0:SetPoint("TOPRIGHT", QTRDateOfBase, "BOTTOMRIGHT", 150, -52);   -- pozycja opisu przycisku CheckBox
  QTRCheckButton0.Text:SetFont(QTR_Font2, 13);
  QTRCheckButton0.Text:SetText(string.utf8reverse(QTR_Interface.active));       -- Aktywuj dodatek
  QTRCheckButton0.Text:SetJustifyH("RIGHT");

  local QTROptionsMode1 = QTROptions:CreateFontString(nil, "ARTWORK");
  QTROptionsMode1:SetFontObject(GameFontWhite);
  QTROptionsMode1:SetJustifyH("RIGHT");
  QTROptionsMode1:SetJustifyV("TOP");
  QTROptionsMode1:ClearAllPoints();
  QTROptionsMode1:SetPoint("TOPRIGHT", QTRDateOfBase, "BOTTOMRIGHT", -10, -120);
  QTROptionsMode1:SetFont(QTR_Font2, 13);
  QTROptionsMode1:SetText(":"..string.utf8reverse(QTR_Interface.settings));          -- Ustawienia dodatku
  
  local QTRCheckButton3 = CreateFrame("CheckButton", "QTRCheckButton3", QTROptions, "SettingsCheckBoxControlTemplate");
  QTRCheckButton3.CheckBox:SetScript("OnClick", function(self) if (QTR_PS["transtitle"]=="0") then QTR_PS["transtitle"]="1" else QTR_PS["transtitle"]="0" end; end);
  QTRCheckButton3.CheckBox:SetPoint("TOPLEFT", QTRDateOfBase, "BOTTOMLEFT", 250, -160);
  QTRCheckButton3:SetPoint("TOPRIGHT", QTRDateOfBase, "BOTTOMRIGHT", 130, -162);
  QTRCheckButton3.Text:SetFont(QTR_Font2, 13);
  QTRCheckButton3.Text:SetText(string.utf8reverse(QTR_Interface.transtitle));   -- Przetłumacz tytuł questu
  QTRCheckButton3.Text:SetJustifyH("RIGHT");

  local QTRCheckButton5 = CreateFrame("CheckButton", "QTRCheckButton5", QTROptions, "SettingsCheckBoxControlTemplate");
  QTRCheckButton5.CheckBox:SetScript("OnClick", function(self) if (QTR_PS["transfixed"]=="1") then QTR_PS["transfixed"]="0" else QTR_PS["transfixed"]="1" end; end);
  QTRCheckButton5.CheckBox:SetPoint("TOPLEFT", QTRCheckButton3.CheckBox, "BOTTOMLEFT", 0, -10);
  QTRCheckButton5:SetPoint("TOPRIGHT", QTRCheckButton3.CheckBox, "BOTTOMRIGHT", 100, -12);
  QTRCheckButton5.Text:SetFont(QTR_Font2, 13);
  QTRCheckButton5.Text:SetText(string.utf8reverse(QTR_Interface.transfixed));         -- Przetłumacz stałe elementy zadań: Objectives, Rewards
  QTRCheckButton5.Text:SetJustifyH("RIGHT");
  
--  local QTRCheckButtonOwnName = CreateFrame("CheckButton", "QTRCheckButtonOwnName", QTROptions, "SettingsCheckBoxControlTemplate");
--  QTRCheckButtonOwnName.CheckBox:SetScript("OnClick", function(self) if (QTR_PS["ownname"]=="1") then QTR_PS["ownname"]="0" else QTR_PS["ownname"]="1" end; end);
--  QTRCheckButtonOwnName.CheckBox:SetPoint("TOPLEFT", QTRCheckButton3.CheckBox, "BOTTOMLEFT", 0, -50);
--  QTRCheckButtonOwnName:SetPoint("TOPRIGHT", QTRCheckButton3.CheckBox, "BOTTOMRIGHT", (-20-string.utf8len(QTR_Interface.ownname)), -52);
--  QTRCheckButtonOwnName.Text:SetFont(QTR_Font2, 13);
--  QTRCheckButtonOwnName.Text:SetText(string.utf8reverse(QTR_Interface.ownname));         -- Wyświetlaj przetłumaczone nazwy własne w języku arabskim  
--  QTRCheckButtonOwnName.Text:SetJustifyH("RIGHT");
  
--  local QTRCheckButtonOwnName2 = CreateFrame("CheckButton", "QTRCheckButtonOwnName2", QTROptions, "SettingsCheckBoxControlTemplate");
--  QTRCheckButtonOwnName2.CheckBox:SetScript("OnClick", function(self) if (QTR_PS["ownname_obj"]=="1") then QTR_PS["ownname_obj"]="0" else QTR_PS["ownname_obj"]="1" end; end);
--  QTRCheckButtonOwnName2.CheckBox:SetPoint("TOPLEFT", QTRCheckButton3.CheckBox, "BOTTOMLEFT", 0, -90);
--  QTRCheckButtonOwnName2:SetPoint("TOPRIGHT", QTRCheckButton3.CheckBox, "BOTTOMRIGHT", (-110-string.utf8len(QTR_Interface.ownname_obj)), -92);
--  QTRCheckButtonOwnName2.Text:SetFont(QTR_Font2, 13);
--  QTRCheckButtonOwnName2.Text:SetText(string.utf8reverse(QTR_Interface.ownname_obj));    -- Nazwy własne w sekcji Zadanie - wyświetlaj zawsze po angielsku
--  QTRCheckButtonOwnName2.Text:SetJustifyH("RIGHT");
  
end



function QTR_wait(delay, func, ...)
  if(type(delay)~="number" or type(func)~="function") then
    return false;
  end
  if (QTR_waitFrame == nil) then
    QTR_waitFrame = CreateFrame("Frame","QTR_WaitFrame", UIParent);
    QTR_waitFrame:SetScript("onUpdate",function (self,elapse)
      local count = #QTR_waitTable;
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(QTR_waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(QTR_waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(QTR_waitTable,{delay,func,{...}});
  return true;
end



function QTR_ON_OFF()
   if (curr_trans=="1") then
      curr_trans="0";
      QTR_Translate_Off(1);
   else   
      curr_trans="1";
      QTR_Translate_On(1);
   end
end


-- Pierwsza funkcja wywoływana po załadowaniu dodatku
function QTR_START()
   -- przycisk z nr ID questu w QuestFrame (NPC)
   QTR_ToggleButton0 = CreateFrame("Button",nil, QuestFrame, "UIPanelButtonTemplate");
   QTR_ToggleButton0:SetWidth(150);
   QTR_ToggleButton0:SetHeight(20);
   QTR_ToggleButton0:SetText("Quest ID=?");
   QTR_ToggleButton0:Show();
   QTR_ToggleButton0:ClearAllPoints();
   QTR_ToggleButton0:SetPoint("TOPLEFT", QuestFrame, "TOPLEFT", 105, -32);
   QTR_ToggleButton0:SetScript("OnClick", QTR_ON_OFF);
   
   -- przycisk z nr ID questu w QuestLogPopupDetailFrame
   QTR_ToggleButton1 = CreateFrame("Button",nil, QuestLogPopupDetailFrame, "UIPanelButtonTemplate");
   QTR_ToggleButton1:SetWidth(150);
   QTR_ToggleButton1:SetHeight(20);
   QTR_ToggleButton1:SetText("Quest ID=?");
   QTR_ToggleButton1:Show();
   QTR_ToggleButton1:ClearAllPoints();
   QTR_ToggleButton1:SetPoint("TOPLEFT", QuestLogPopupDetailFrame, "TOPLEFT", 45, -31);
   QTR_ToggleButton1:SetScript("OnClick", QTR_ON_OFF);

   -- przycisk z nr ID questu w QuestMapDetailsScrollFrame
   QTR_ToggleButton2 = CreateFrame("Button",nil, QuestMapDetailsScrollFrame, "UIPanelButtonTemplate");
   QTR_ToggleButton2:SetWidth(150);
   QTR_ToggleButton2:SetHeight(20);
   QTR_ToggleButton2:SetText("Quest ID=?");
   QTR_ToggleButton2:Show();
   QTR_ToggleButton2:ClearAllPoints();
   QTR_ToggleButton2:SetPoint("TOPLEFT", QuestMapDetailsScrollFrame, "TOPLEFT", 116, 29);
   QTR_ToggleButton2:SetScript("OnClick", QTR_ON_OFF);


   WorldMapFrame:HookScript("OnShow", function() 
      if (not QTR_wait(0.2, QTR_QuestScrollFrame_OnShow)) then
      -- opóźnienie 0.2 sek
      end
   end );
   
   -- funkcja wywoływana po kliknięciu na nazwę questu w QuestMapFrame
   hooksecurefunc("QuestMapFrame_ShowQuestDetails", QTR_PrepareReload);
   
   -- funkcja wywoływana po wyświetleniu się obiektu GreetingText w oknie QuestFrame
   QuestFrameAcceptButton:HookScript("OnClick", QTR_QuestFrameButton_OnClick);
   QuestFrameCompleteQuestButton:HookScript("OnClick", QTR_QuestFrameButton_OnClick);
   QuestLogPopupDetailFrame:HookScript("OnShow", QTR_QuestLogPopupShow);
   
   QTR:RegisterEvent("CHAT_MSG_ADDON");      -- ukryty kanał addonu
   C_ChatInfo.RegisterAddonMessagePrefix("WoWinArabic_QTR");
   
end


function QTR_QuestLogPopupShow()
   if (QuestLogPopupDetailFrame:IsVisible()) then
      QTR_QuestPrepare("QUEST_DETAIL");
   end
end


-- Kolejny quest w otwartym już oknie QuestFrame?
function QTR_QuestFrameButton_OnClick()
   if (not QTR_wait(0.5, QTR_QuestFrameWithoutOpenQuestFrame)) then
      -- opóźnienie 0.5 sek
   end
end




function Spr_Gender(msg)         -- miało być używane w QTR_Messages.itemchoose1 - na razie wyłączone
   local nr_1, nr_2, nr_3 = 0;
   local QTR_forma = "";
   local nr_poz = string.find(msg, "YOUR_GENDER");    -- gdy nie znalazł, jest: nil; liczy od 1
   while (nr_poz and nr_poz>0) do
      nr_1 = nr_poz + 1;   
      while (string.sub(msg, nr_1, nr_1) ~= "(") do   -- szukaj nawiasu otwierającego
         nr_1 = nr_1 + 1;
      end
      if (string.sub(msg, nr_1, nr_1) == "(") then
         nr_2 =  nr_1 + 1;
         while (string.sub(msg, nr_2, nr_2) ~= ";") do   -- szukaj średnika oddzielającego
            nr_2 = nr_2 + 1;
         end
         if (string.sub(msg, nr_2, nr_2) == ";") then
            nr_3 = nr_2 + 1;
            while (string.sub(msg, nr_3, nr_3) ~= ")") do   -- szykaj nawiasu zamykającego
               nr_3 = nr_3 + 1;
            end
            if (string.sub(msg, nr_3, nr_3) == ")") then
               if (QTR_sex==3) then        -- forma żeńska
                  QTR_forma = string.sub(msg,nr_2+1,nr_3-1);
               else                        -- forma męska
                  QTR_forma = string.sub(msg,nr_1+1,nr_2-1);
               end
               msg = string.sub(msg,1,nr_poz-1) .. QTR_forma .. string.sub(msg,nr_3+1);
            end   
         end
      end
      nr_poz = string.find(msg, "YOUR_GENDER");
   end
   return msg;
end


-- Określa aktualny numer ID questu z różnych metod
function QTR_GetQuestID()
   local quest_ID;
   
   if (QuestFrame:IsVisible() and (isGetQuestID=="1")) then
      quest_ID = GetQuestID();
   end
   
   if (QuestMapDetailsScrollFrame:IsVisible() and ((quest_ID==nil) or (quest_ID==0))) then
      quest_ID = QuestMapFrame.DetailsFrame.questID;
   end         

   if (QuestLogPopupDetailFrame:IsVisible() and ((quest_ID==nil) or (quest_ID==0))) then
      quest_ID = QuestLogPopupDetailFrame.questID;
   end
      
   if (quest_ID==nil) then
      quest_ID=0;
   end   
   
   return (quest_ID);
end


-- Wywoływane przy przechwytywanych zdarzeniach
function QTR_OnEvent(self, event, name, ...)
   if (event=="ADDON_LOADED" and name=="WoWinArabic_Quests") then
      QTR_START();
      SlashCmdList["WOWINARABIC_QUESTS"] = function(msg) QTR_SlashCommand(msg); end
      SLASH_WOWINARABIC_QUESTS1 = "/wowinarabic-quests";
      SLASH_WOWINARABIC_QUESTS2 = "/qtr";
      QTR_CheckVars();
      -- twórz interface Options w Blizzard-Interface-Addons
      QTR_BlizzardOptions();
      print ("|cffffff00WoWinArabic-Quests ver. "..QTR_version.." - "..QTR_Messages.started);
      QTR:UnregisterEvent("ADDON_LOADED");
      QTR.ADDON_LOADED = nil;
            
--      QTR_Messages.itemchoose1 = Spr_Gender(QTR_Messages.itemchoose1);
      if (not isGetQuestID) then
         DetectEmuServer();
      end
   elseif (event=="QUEST_DETAIL" or event=="QUEST_PROGRESS" or event=="QUEST_COMPLETE") then
      if ( QuestFrame:IsVisible() ) then
         QTR_QuestPrepare(event);
      end	-- QuestFrame is Visible
   end
end


-- Otworzono okienko QuestLogPopupDetailFrame lub QuestMapDetailsScrollFrame
function QTR_QuestPrepare(zdarzenie)
   q_ID = QTR_GetQuestID();         -- uzyskaj aktualne ID questu
   if (q_ID==0) then
      return
   end   

   QTR_quest_ID = q_ID;
   str_ID = tostring(q_ID);
   if ( not (QTR_quest_EN[QTR_quest_ID])) then
      QTR_quest_EN[QTR_quest_ID] = { };
      QTR_quest_LG[QTR_quest_ID] = { };
   end
   if ( QTR_PS["active"]=="1" ) then	-- tłumaczenia włączone
      QTR_ToggleButton0:Enable();      -- przycisk w ramce QuestFrame (NPC)
      QTR_ToggleButton1:Enable();      -- przycisk w ramce QuestLogPopupDetailFrame
      QTR_ToggleButton2:Enable();      -- przycisk w ramce QuestMapDetailsScrollFrame
      curr_trans = "1";                -- aktualnie wyświetlane jest tłumaczenie PL
      if ( QTR_QuestData[str_ID] ) then   -- wyświetlaj tylko, gdy istnieje tłumaczenie
         if (QTR_quest_EN[QTR_quest_ID].title == nil) then
            QTR_quest_LG[QTR_quest_ID].title = QTR_ExpandUnitInfo(QTR_QuestData[str_ID]["Title"],false);
            QTR_quest_EN[QTR_quest_ID].title = GetTitleText();
            if (QTR_quest_EN[QTR_quest_ID].title=="") then
               QTR_quest_EN[QTR_quest_ID].title=QuestInfoTitleHeader:GetText();
            end
         end
         if (QTR_quest_LG[QTR_quest_ID].details == nil) then
            QTR_quest_LG[QTR_quest_ID].details = QTR_ExpandUnitInfo(QTR_QuestData[str_ID]["Description"],false);
            QTR_quest_LG[QTR_quest_ID].objectives = QTR_ExpandUnitInfo(QTR_QuestData[str_ID]["Objectives"],false);
         end
         if (zdarzenie=="QUEST_DETAIL") then
            if (QTR_quest_EN[QTR_quest_ID].details == nil) then
               QTR_quest_EN[QTR_quest_ID].details = GetQuestText();
               QTR_quest_EN[QTR_quest_ID].objectives = GetObjectiveText();
            end
            -- sprawdź ile jest nagród za ten quest?
            quest_numReward[str_ID] = GetNumQuestChoices();
            if (quest_numReward[str_ID]>1) then
               QTR_quest_EN[QTR_quest_ID].itemchoose = QTR_MessOrig.itemchoose1;
               QTR_quest_LG[QTR_quest_ID].itemchoose = QTR_Messages.itemchoose1;
            else
               QTR_quest_EN[QTR_quest_ID].itemchoose = QTR_MessOrig.itemchoose0;
               QTR_quest_LG[QTR_quest_ID].itemchoose = QTR_Messages.itemchoose0;
            end
            -- czy jest jeszcze kasa w nagrodę? a może jest tylko sama kasa?
            if (quest_numReward[str_ID]>0) then
               QTR_quest_EN[QTR_quest_ID].itemreceive = QTR_MessOrig.itemreceiv1;
               QTR_quest_LG[QTR_quest_ID].itemreceive = QTR_Messages.itemreceiv1;
            else
               QTR_quest_EN[QTR_quest_ID].itemreceive = QTR_MessOrig.itemreceiv0;
               QTR_quest_LG[QTR_quest_ID].itemreceive = QTR_Messages.itemreceiv0;
            end
         else        -- nie jest to zdarzenie QUEST_DETAILS
            if (QTR_quest_EN[QTR_quest_ID].details == nil) then
               QTR_quest_EN[QTR_quest_ID].details = QuestInfoDescriptionText:GetText();
            end
            if (QTR_quest_EN[QTR_quest_ID].objectives == nil) then
               QTR_quest_EN[QTR_quest_ID].objectives = QuestInfoObjectivesText:GetText();
            end
            if (quest_numReward[str_ID]==nil) then         -- mamy zapamiętaną liczbę nagród do tego questu
               QTR_quest_EN[QTR_quest_ID].itemchoose = QTR_MessOrig.itemchoose0;
               QTR_quest_LG[QTR_quest_ID].itemchoose = QTR_Messages.itemchoose0;
               if (MapQuestInfoRewardsFrame.ItemChooseText:IsVisible()) then
                  QTR_quest_EN[QTR_quest_ID].itemreceive = QTR_MessOrig.itemreceiv1;
                  QTR_quest_LG[QTR_quest_ID].itemreceive = QTR_Messages.itemreceiv1;                  
               else
                  QTR_quest_EN[QTR_quest_ID].itemreceive = QTR_MessOrig.itemreceiv0;
                  QTR_quest_LG[QTR_quest_ID].itemreceive = QTR_Messages.itemreceiv0;
               end
            else
               if (quest_numReward[str_ID]>1) then
                  QTR_quest_EN[QTR_quest_ID].itemchoose = QTR_MessOrig.itemchoose1;
                  QTR_quest_LG[QTR_quest_ID].itemchoose = QTR_Messages.itemchoose1;
               else
                  QTR_quest_EN[QTR_quest_ID].itemchoose = QTR_MessOrig.itemchoose0;
                  QTR_quest_LG[QTR_quest_ID].itemchoose = QTR_Messages.itemchoose0;
               end
               -- czy jest jeszcze kasa w nagrodę? a może jest tylko sama kasa?
               if (quest_numReward[str_ID]>0) then
                  QTR_quest_EN[QTR_quest_ID].itemreceive = QTR_MessOrig.itemreceiv1;
                  QTR_quest_LG[QTR_quest_ID].itemreceive = QTR_Messages.itemreceiv1;
               else
                  QTR_quest_EN[QTR_quest_ID].itemreceive = QTR_MessOrig.itemreceiv0;
                  QTR_quest_LG[QTR_quest_ID].itemreceive = QTR_Messages.itemreceiv0;
               end
            end
         end   
         if (zdarzenie=="QUEST_PROGRESS") then
            if (QTR_quest_EN[QTR_quest_ID].progress == nil) then
               QTR_quest_EN[QTR_quest_ID].progress = GetProgressText();
               QTR_quest_LG[QTR_quest_ID].progress = QTR_ExpandUnitInfo(QTR_QuestData[str_ID]["Progress"],false);
            end
            if (strlen(QTR_quest_LG[QTR_quest_ID].progress)==0) then      -- treść jest pusta, a otworzono okienko Progress
               QTR_quest_LG[QTR_quest_ID].progress = QTR_ExpandUnitInfo('YOUR_NAME أنت بخير يا',false);
            end
         end
         if (zdarzenie=="QUEST_COMPLETE") then
            if (QTR_quest_EN[QTR_quest_ID].completion == nil) then
               QTR_quest_EN[QTR_quest_ID].completion = GetRewardText();
               QTR_quest_LG[QTR_quest_ID].completion = QTR_ExpandUnitInfo(QTR_QuestData[str_ID]["Completion"],false);
            end
            -- sprawdź ile jest nagród za ten quest?
            if (quest_numReward[str_ID]==nil) then
               quest_numReward[str_ID] = GetNumQuestChoices();
            end
            if (quest_numReward[str_ID]>1) then
               QTR_quest_EN[QTR_quest_ID].itemchoose = QTR_MessOrig.itemchoose2;
               QTR_quest_LG[QTR_quest_ID].itemchoose = QTR_Messages.itemchoose2;
            else
               QTR_quest_EN[QTR_quest_ID].itemchoose = QTR_MessOrig.itemchoose3;
               QTR_quest_LG[QTR_quest_ID].itemchoose = QTR_Messages.itemchoose3;
            end
            -- czy jest jeszcze kasa w nagrodę? a może jest tylko sama kasa?
            if (quest_numReward[str_ID]>0) then
               QTR_quest_EN[QTR_quest_ID].itemreceive = QTR_MessOrig.itemreceiv3;
               QTR_quest_LG[QTR_quest_ID].itemreceive = QTR_Messages.itemreceiv3;
            else
               QTR_quest_EN[QTR_quest_ID].itemreceive = QTR_MessOrig.itemreceiv2;
               QTR_quest_LG[QTR_quest_ID].itemreceive = QTR_Messages.itemreceiv2;
            end
         end         
         QTR_ToggleButton0:SetText("Quest ID="..QTR_quest_ID.." ("..QTR_lang..")");
         QTR_ToggleButton1:SetText("Quest ID="..QTR_quest_ID.." ("..QTR_lang..")");
         QTR_ToggleButton2:SetText("Quest ID="..QTR_quest_ID.." ("..QTR_lang..")");
         QTR_Translate_On(1);
         if (QTR_first_show==0) then      -- pierwsze wyświetlenie, daj opóźnienie i przełączaj, bo nie wyświetla danych stałych 
            if (not QTR_wait(0.2,QTR_ON_OFF)) then    -- przeładuj wpierw na OFF
            ---
            end
            if (not QTR_wait(0.2,QTR_ON_OFF)) then    -- przeładuj ponownie na ON
            ---
            end
            QTR_first_show=1;
         end
      else	      -- nie ma przetłumaczonego takiego questu
         QTR_ToggleButton0:Disable();     -- przycisk w ramce QuestFrame (NPC)
         QTR_ToggleButton1:Disable();     -- przycisk w ramce QuestLogPopupDetailFrame
         QTR_ToggleButton2:Disable();     -- przycisk w ramce QuestMapDetailsScrollFrame
         QTR_ToggleButton0:SetText("Quest ID="..str_ID);
         QTR_ToggleButton1:SetText("Quest ID="..str_ID);
         QTR_ToggleButton2:SetText("Quest ID="..str_ID);
         QTR_Translate_On(0);
      end -- jest przetłumaczony quest w bazie
   else	-- tłumaczenia wyłączone
      QTR_ToggleButton0:Disable();        -- przycisk w ramce QuestFrame (NPC)
      QTR_ToggleButton1:Disable();        -- przycisk w ramce QuestLogPopupDetailFrame
      QTR_ToggleButton2:Disable();        -- przycisk w ramce QuestMapDetailsScrollFrame
      if ( QTR_QuestData[str_ID] ) then	-- ale jest tłumaczenie w bazie
         QTR_ToggleButton1:SetText("Quest ID="..str_ID.." (EN)");
         QTR_ToggleButton2:SetText("Quest ID="..str_ID.." (EN)");
      else
         QTR_ToggleButton1:SetText("Quest ID="..str_ID);
         QTR_ToggleButton2:SetText("Quest ID="..str_ID);
      end
   end	-- tłumaczenia są włączone
end


-- wyświetla tłumaczenie
function QTR_Translate_On(typ)
   if (QTR_PS["transfixed"]=="1") then
      QTR_display_constants(1);
   end
--   if (QuestNPCModelText:IsVisible() and (QTR_ModelTextHash>0)) then         -- jest wyświetlony tekst QuestNPCModelText
--      QuestNPCModelText:SetFont(QTR_Font2, 13);
--      QuestNPCModelText:SetJustifyH("RIGHT");         -- wyrównanie od prawego
--      QuestNPCModelText:SetText(QTR_Reverse(QTR_ModelText_PL,QTR_limit3));   -- tłumaczenie z bazy Gossip
--   end
   
   if (typ==1) then			-- pełne przełączenie (jest tłumaczenie)
      local numer_ID = QTR_quest_ID;
      str_ID = tostring(numer_ID);
      if (numer_ID>0 and QTR_QuestData[str_ID]) then	-- przywróć przetłumaczoną wersję napisów
         QTR_ToggleButton0:SetText("Quest ID="..QTR_quest_ID.." ("..QTR_lang..")");
         QTR_ToggleButton1:SetText("Quest ID="..QTR_quest_ID.." ("..QTR_lang..")");
         QTR_ToggleButton2:SetText("Quest ID="..QTR_quest_ID.." ("..QTR_lang..")");
         if ((QTR_PS["transtitle"]=="1") and QTR_quest_LG[QTR_quest_ID].title) then
            QuestInfoTitleHeader:SetFont(QTR_Font1, 18);
            QuestInfoTitleHeader:SetJustifyH("RIGHT");         -- wyrównanie od prawego
            QuestInfoTitleHeader:SetText(string.utf8reverse(QTR_quest_LG[QTR_quest_ID].title));
            QuestProgressTitleText:SetFont(QTR_Font1, 18);
            QuestProgressTitleText:SetJustifyH("RIGHT");       -- wyrównanie od prawego
            QuestProgressTitleText:SetText(string.utf8reverse(QTR_quest_LG[QTR_quest_ID].title));
         end
         local QTR_limit12 = 50;
         if (WorldMapFrame:IsVisible()) then
            QTR_limit12 = QTR_limit2;
         else
            QTR_limit12 = QTR_limit1;
         end
         QuestInfoDescriptionText:SetFont(QTR_Font2, 16);
         if (QTR_quest_LG[QTR_quest_ID].details) then
            QuestInfoDescriptionText:SetJustifyH("RIGHT");        -- wyrównanie od prawego
            QuestInfoDescriptionText:SetText(QTR_Reverse(QTR_quest_LG[QTR_quest_ID].details, QTR_limit12));
         else
            QuestInfoDescriptionText:SetText(QTR_Messages.missing);
         end
         QuestInfoObjectivesText:SetFont(QTR_Font2, 16);
         if (QTR_quest_LG[QTR_quest_ID].objectives) then
            QuestInfoObjectivesText:SetJustifyH("RIGHT");         -- wyrównanie od prawego
--            QuestInfoObjectivesText:SetText(string.utf8reverse(QTR_quest_LG[QTR_quest_ID].objectives));
            QuestInfoObjectivesText:SetText(QTR_Reverse(QTR_quest_LG[QTR_quest_ID].objectives, QTR_limit12));
         else
            QuestInfoObjectivesText:SetText(QTR_Messages.missing);
         end
         QuestProgressText:SetFont(QTR_Font2, 16);
         if (QTR_quest_LG[QTR_quest_ID].progress) then
            QuestProgressText:SetJustifyH("RIGHT");               -- wyrównanie od prawego
            QuestProgressText:SetText(QTR_Reverse(QTR_quest_LG[QTR_quest_ID].progress, QTR_limit12));
         else
--            QuestProgressText:SetJustifyH("LEFT");               -- wyrównanie od lewego
            QuestProgressText:SetText(QTR_Messages.missing);
         end
         QuestInfoRewardText:SetFont(QTR_Font2, 16);
         if (QTR_quest_LG[QTR_quest_ID].completion) then
            QuestInfoRewardText:SetJustifyH("RIGHT");             -- wyrównanie od prawego
            QuestInfoRewardText:SetText(QTR_Reverse(QTR_quest_LG[QTR_quest_ID].completion, QTR_limit12));
         else
            QuestInfoRewardText:SetText(QTR_Messages.missing);
         end
      end
      if ( (QuestInfoDescriptionText~=QTR_quest_LG[QTR_quest_ID].details) and (QTR_first_show2 == 0) ) then   -- nie wczytały się tłumaczenia
         QTR_first_show2 = 1;
         if (not QTR_wait(0.2,QTR_ON_OFF)) then    -- przeładuj wpierw na OFF
         ---
         end
         if (not QTR_wait(0.2,QTR_ON_OFF)) then    -- przeładuj ponownie na ON
         ---
         end
      end
   end
end


-- wyświetla oryginalny tekst angielski
function QTR_Translate_Off(typ)
   if (QTR_PS["transfixed"]=="1") then
      QTR_display_constants(0);
   end
--   if (QuestNPCModelText:IsVisible() and (QTR_ModelTextHash>0)) then         -- jest wyświetlony tekst QuestNPCModelText
--      QuestNPCModelText:SetFont(Original_Font2, 13);
--      QuestNPCModelText:SetJustifyH("LEFT");         -- wyrównanie od lewego
--      QuestNPCModelText:SetText(QTR_ModelText_EN);
--   end
   
   if (typ==1) then			-- pełne przełączenie (jest tłumaczenie)
      local numer_ID = QTR_quest_ID;
      str_ID = tostring(numer_ID);
      if (numer_ID>0 and QTR_QuestData[str_ID]) then	-- przywróć oryginalną wersję napisów
         QTR_ToggleButton0:SetText("Quest ID="..QTR_quest_ID.." (EN)");
         QTR_ToggleButton1:SetText("Quest ID="..QTR_quest_ID.." (EN)");
         QTR_ToggleButton2:SetText("Quest ID="..QTR_quest_ID.." (EN)");
         QuestInfoTitleHeader:SetFont(Original_Font1, 18);
         QuestInfoTitleHeader:SetJustifyH("LEFT");         -- wyrównanie od lewego
         QuestInfoTitleHeader:SetText(QTR_quest_EN[QTR_quest_ID].title);
         QuestProgressTitleText:SetFont(Original_Font1, 18);
         QuestProgressTitleText:SetJustifyH("LEFT");         -- wyrównanie od lewego
         QuestProgressTitleText:SetText(QTR_quest_EN[QTR_quest_ID].title);
         QuestInfoDescriptionText:SetFont(Original_Font2, 13);
         QuestInfoDescriptionText:SetJustifyH("LEFT");         -- wyrównanie od lewego
         QuestInfoDescriptionText:SetText(QTR_quest_EN[QTR_quest_ID].details);
         QuestInfoObjectivesText:SetFont(Original_Font2, 13);
         QuestInfoObjectivesText:SetJustifyH("LEFT");         -- wyrównanie od lewego
         QuestInfoObjectivesText:SetText(QTR_quest_EN[QTR_quest_ID].objectives);
         QuestProgressText:SetFont(Original_Font2, 13);
         QuestProgressText:SetJustifyH("LEFT");         -- wyrównanie od lewego
         QuestProgressText:SetText(QTR_quest_EN[QTR_quest_ID].progress);
         QuestInfoRewardText:SetFont(Original_Font2, 13);
         QuestInfoRewardText:SetJustifyH("LEFT");         -- wyrównanie od lewego
         QuestInfoRewardText:SetText(QTR_quest_EN[QTR_quest_ID].completion);
      end
   end
end


function QTR_display_constants(lg)
   if (lg==1) then        -- dane stałe po arabsku
      QuestInfoObjectivesHeader:SetFont(QTR_Font1, 18);
      QuestInfoObjectivesHeader:SetJustifyH("RIGHT");             -- wyrównanie od prawego
      QuestInfoObjectivesHeader:SetText(string.utf8reverse(QTR_Messages.objectives));
      QuestInfoRewardsFrame.Header:SetFont(QTR_Font1, 18);
      QuestInfoRewardsFrame.Header:SetJustifyH("RIGHT");          -- wyrównanie od prawego
      QuestInfoRewardsFrame.Header:SetText(string.utf8reverse(QTR_Messages.rewards));
      QuestInfoDescriptionHeader:SetFont(QTR_Font1, 18);
      QuestInfoDescriptionHeader:SetJustifyH("RIGHT");            -- wyrównanie od prawego
      QuestInfoDescriptionHeader:SetText(string.utf8reverse(QTR_Messages.details));
      QuestProgressRequiredItemsText:SetFont(QTR_Font1, 18);
      QuestProgressRequiredItemsText:SetJustifyH("RIGHT");        -- wyrównanie od prawego
      QuestProgressRequiredItemsText:SetText(string.utf8reverse(QTR_Messages.reqitems));
      CurrentQuestsText:SetFont(QTR_Font1, 18);
      CurrentQuestsText:SetJustifyH("RIGHT");                     -- wyrównanie od prawego
      CurrentQuestsText:SetText(string.utf8reverse(QTR_Messages.currquests));
      AvailableQuestsText:SetFont(QTR_Font1, 18);
      AvailableQuestsText:SetJustifyH("RIGHT");                   -- wyrównanie od prawego
      AvailableQuestsText:SetText(string.utf8reverse(QTR_Messages.avaiquests));
      local regions = { QuestMapFrame.DetailsFrame.RewardsFrame:GetRegions() };
      for index = 1, #regions do
         local region = regions[index];
         if ((region:GetObjectType() == "FontString") and (region:GetText() == QUEST_REWARDS)) then
            local _font1, _size1, _3 = region:GetFont();    -- odczytaj aktualną czcionkę i rozmiar
            region:SetFont(QTR_Font1, _size1);
            region:SetJustifyH("RIGHT");                          -- wyrównanie od prawego
            region:SetText(string.utf8reverse(QTR_Messages.rewards));
         end
      end
      
      -- stałe elementy okna zadania:
      QuestInfoRewardsFrame.ItemChooseText:SetFont(QTR_Font2, 13);
      QuestInfoRewardsFrame.ItemChooseText:SetJustifyH("RIGHT");                  -- wyrównanie od prawego
      QuestInfoRewardsFrame.ItemChooseText:SetText(string.utf8reverse(QTR_quest_LG[QTR_quest_ID].itemchoose));
      QuestInfoRewardsFrame.ItemReceiveText:SetFont(QTR_Font2, 13);
      QuestInfoRewardsFrame.ItemReceiveText:SetJustifyH("RIGHT");                 -- wyrównanie od prawego
      QuestInfoRewardsFrame.ItemReceiveText:SetText(string.utf8reverse(QTR_quest_LG[QTR_quest_ID].itemreceive));
      QuestInfoSpellObjectiveLearnLabel:SetFont(QTR_Font2, 13);
      QuestInfoSpellObjectiveLearnLabel:SetJustifyH("RIGHT");                     -- wyrównanie od prawego
      QuestInfoSpellObjectiveLearnLabel:SetText(string.utf8reverse(QTR_Messages.learnspell));
      QuestInfoXPFrame.ReceiveText:SetFont(QTR_Font2, 13);
      QuestInfoXPFrame.ReceiveText:SetJustifyH("RIGHT");                          -- wyrównanie od prawego
      QuestInfoXPFrame.ReceiveText:SetText(string.utf8reverse(QTR_Messages.experience));
      QuestInfoRewardsFrame.XPFrame.ReceiveText:SetFont(QTR_Font2, 13);
      QuestInfoRewardsFrame.XPFrame.ReceiveText:SetJustifyH("RIGHT");             -- wyrównanie od prawego
      QuestInfoRewardsFrame.XPFrame.ReceiveText:SetText(string.utf8reverse(QTR_Messages.experience));
      MapQuestInfoRewardsFrame.ItemChooseText:SetFont(QTR_Font2, 11);
      MapQuestInfoRewardsFrame.ItemChooseText:SetJustifyH("RIGHT");               -- wyrównanie od prawego
      MapQuestInfoRewardsFrame.ItemChooseText:SetText(string.utf8reverse(QTR_quest_LG[QTR_quest_ID].itemchoose));
      MapQuestInfoRewardsFrame.ItemReceiveText:SetFont(QTR_Font2, 11);
      MapQuestInfoRewardsFrame.ItemReceiveText:SetJustifyH("RIGHT");              -- wyrównanie od prawego
      MapQuestInfoRewardsFrame.ItemReceiveText:SetText(string.utf8reverse(QTR_quest_LG[QTR_quest_ID].itemreceive));
      QuestInfoRewardsFrame.PlayerTitleText:SetFont(QTR_Font2, 13);
      QuestInfoRewardsFrame.PlayerTitleText:SetJustifyH("RIGHT");                 -- wyrównanie od prawego
      QuestInfoRewardsFrame.PlayerTitleText:SetText(string.utf8reverse(QTR_Messages.reward_title));
      QuestInfoRewardsFrame.QuestSessionBonusReward:SetFont(QTR_Font2, 13);
      QuestInfoRewardsFrame.QuestSessionBonusReward:SetJustifyH("RIGHT");         -- wyrównanie od prawego
      QuestInfoRewardsFrame.QuestSessionBonusReward:SetText(string.utf8reverse(QTR_Messages.reward_bonus));
      if ( QuestInfoRewardsFrame:IsVisible() ) then
         for fontString in QuestInfoRewardsFrame.spellHeaderPool:EnumerateActive() do
            if (fontString:GetText() == REWARD_AURA) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(string.utf8reverse(QTR_Messages.reward_aura));
            end
            if (fontString:GetText() == REWARD_SPELL) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(string.utf8reverse(QTR_Messages.reward_spell));
            end
            if (fontString:GetText() == REWARD_COMPANION) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(string.utf8reverse(QTR_Messages.reward_companion));
            end
            if (fontString:GetText() == REWARD_FOLLOWER) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(string.utf8reverse(QTR_Messages.reward_follower));
            end
            if (fontString:GetText() == REWARD_REPUTATION) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(string.utf8reverse(QTR_Messages.reward_reputation));
            end
            if (fontString:GetText() == REWARD_TITLE) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(string.utf8reverse(QTR_Messages.reward_title));
            end
            if (fontString:GetText() == REWARD_TRADESKILL) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(string.utf8reverse(QTR_Messages.reward_tradeskill));
            end
            if (fontString:GetText() == REWARD_UNLOCK) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(string.utf8reverse(QTR_Messages.reward_unlock));
            end
            if (fontString:GetText() == REWARD_BONUS) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(string.utf8reverse(QTR_Messages.reward_bonus));
            end
         end
      end
      if ( MapQuestInfoRewardsFrame:IsVisible() ) then
         for fontString in MapQuestInfoRewardsFrame.spellHeaderPool:EnumerateActive() do
            if (fontString:GetText() == REWARD_AURA) then
               fontString:SetFont(QTR_Font2, 11);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(string.utf8reverse(QTR_Messages.reward_aura));
            end
            if (fontString:GetText() == REWARD_SPELL) then
               fontString:SetFont(QTR_Font2, 11);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(string.utf8reverse(QTR_Messages.reward_spell));
            end
            if (fontString:GetText() == REWARD_COMPANION) then
               fontString:SetFont(QTR_Font2, 11);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(string.utf8reverse(QTR_Messages.reward_companion));
            end
            if (fontString:GetText() == REWARD_FOLLOWER) then
               fontString:SetFont(QTR_Font2, 11);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(string.utf8reverse(QTR_Messages.reward_follower));
            end
            if (fontString:GetText() == REWARD_REPUTATION) then
               fontString:SetFont(QTR_Font2, 11);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(string.utf8reverse(QTR_Messages.reward_reputation));
            end
            if (fontString:GetText() == REWARD_TITLE) then
               fontString:SetFont(QTR_Font2, 11);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(string.utf8reverse(QTR_Messages.reward_title));
            end
            if (fontString:GetText() == REWARD_TRADESKILL) then
               fontString:SetFont(QTR_Font2, 11);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(string.utf8reverse(QTR_Messages.reward_tradeskill));
            end
            if (fontString:GetText() == REWARD_UNLOCK) then
               fontString:SetFont(QTR_Font2, 11);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(string.utf8reverse(QTR_Messages.reward_unlock));
            end
            if (fontString:GetText() == REWARD_BONUS) then
               fontString:SetFont(QTR_Font2, 11);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(string.utf8reverse(QTR_Messages.reward_bonus));
            end
         end
      end
      
   else                 --   przywróć pierwotną zawartość elementów po angielsku
   
      QuestInfoObjectivesHeader:SetFont(Original_Font1, 18);
      QuestInfoObjectivesHeader:SetJustifyH("LEFT");         -- wyrównanie od lewego
      QuestInfoObjectivesHeader:SetText(QTR_MessOrig.objectives);
      QuestInfoRewardsFrame.Header:SetFont(Original_Font1, 18);
      QuestInfoRewardsFrame.Header:SetJustifyH("LEFT");         -- wyrównanie od lewego
      QuestInfoRewardsFrame.Header:SetText(QTR_MessOrig.rewards);
      QuestInfoDescriptionHeader:SetFont(Original_Font1, 18);
      QuestInfoDescriptionHeader:SetJustifyH("LEFT");         -- wyrównanie od lewego
      QuestInfoDescriptionHeader:SetText(QTR_MessOrig.details);
      QuestProgressRequiredItemsText:SetFont(Original_Font1, 18);
      QuestProgressRequiredItemsText:SetJustifyH("LEFT");         -- wyrównanie od lewego
      QuestProgressRequiredItemsText:SetText(QTR_MessOrig.reqitems);
      CurrentQuestsText:SetFont(Original_Font1, 18);
      CurrentQuestsText:SetJustifyH("LEFT");         -- wyrównanie od lewego
      CurrentQuestsText:SetText(QTR_MessOrig.currquests);
      AvailableQuestsText:SetFont(Original_Font1, 18);
      AvailableQuestsText:SetJustifyH("LEFT");         -- wyrównanie od lewego
      AvailableQuestsText:SetText(QTR_MessOrig.avaiquests);
      local regions = { QuestMapFrame.DetailsFrame.RewardsFrame:GetRegions() };
      for index = 1, #regions do
         local region = regions[index];
         if ((region:GetObjectType() == "FontString") and (region:GetText() == QTR_Messages.rewards)) then
            local _font2, _size2, _3 = region:GetFont();    -- odczytaj aktualną czcionkę i rozmiar
            region:SetFont(Original_Font1, _size2);
            region:SetJustifyH("LEFT");         -- wyrównanie od lewego
            region:SetText(QUEST_REWARDS);
         end
      end
      
      -- stałe elementy okna zadania:
      QuestInfoRewardsFrame.ItemChooseText:SetFont(Original_Font2, 13);
      QuestInfoRewardsFrame.ItemChooseText:SetJustifyH("LEFT");         -- wyrównanie od lewego
      QuestInfoRewardsFrame.ItemChooseText:SetText(QTR_quest_EN[QTR_quest_ID].itemchoose);
      QuestInfoRewardsFrame.ItemReceiveText:SetFont(Original_Font2, 13);
      QuestInfoRewardsFrame.ItemReceiveText:SetJustifyH("LEFT");         -- wyrównanie od lewego
      QuestInfoRewardsFrame.ItemReceiveText:SetText(QTR_quest_EN[QTR_quest_ID].itemreceive);
      QuestInfoSpellObjectiveLearnLabel:SetFont(Original_Font2, 13);
      QuestInfoSpellObjectiveLearnLabel:SetJustifyH("LEFT");         -- wyrównanie od lewego
      QuestInfoSpellObjectiveLearnLabel:SetText(QTR_MessOrig.learnspell);
      QuestInfoXPFrame.ReceiveText:SetFont(Original_Font2, 13);
      QuestInfoXPFrame.ReceiveText:SetJustifyH("LEFT");         -- wyrównanie od lewego
      QuestInfoXPFrame.ReceiveText:SetText(QTR_MessOrig.experience);
      QuestInfoRewardsFrame.XPFrame.ReceiveText:SetFont(Original_Font2, 13);
      QuestInfoRewardsFrame.XPFrame.ReceiveText:SetJustifyH("LEFT");         -- wyrównanie od lewego
      QuestInfoRewardsFrame.XPFrame.ReceiveText:SetText(QTR_MessOrig.experience);
      MapQuestInfoRewardsFrame.ItemChooseText:SetFont(Original_Font2, 11);
      MapQuestInfoRewardsFrame.ItemChooseText:SetJustifyH("LEFT");         -- wyrównanie od lewego
      MapQuestInfoRewardsFrame.ItemChooseText:SetText(QTR_quest_EN[QTR_quest_ID].itemchoose);
      MapQuestInfoRewardsFrame.ItemReceiveText:SetFont(Original_Font2, 11);
      MapQuestInfoRewardsFrame.ItemReceiveText:SetJustifyH("LEFT");         -- wyrównanie od lewego
      MapQuestInfoRewardsFrame.ItemReceiveText:SetText(QTR_quest_EN[QTR_quest_ID].itemreceive);
      QuestInfoRewardsFrame.PlayerTitleText:SetFont(Original_Font2, 13);
      QuestInfoRewardsFrame.PlayerTitleText:SetJustifyH("LEFT");         -- wyrównanie od lewego
      QuestInfoRewardsFrame.PlayerTitleText:SetText(QTR_MessOrig.reward_title);
      QuestInfoRewardsFrame.QuestSessionBonusReward:SetFont(Original_Font2, 13);
      QuestInfoRewardsFrame.QuestSessionBonusReward:SetJustifyH("LEFT");         -- wyrównanie od lewego
      QuestInfoRewardsFrame.QuestSessionBonusReward:SetText(QTR_MessOrig.reward_bonus);
      if ( QuestInfoRewardsFrame:IsVisible() ) then
         for fontString in QuestInfoRewardsFrame.spellHeaderPool:EnumerateActive() do
            if (fontString:GetText() == QTR_Messages.reward_aura) then
               fontString:SetFont(Original_Font2, 13);
               fontString:SetJustifyH("LEFT");         -- wyrównanie od lewego
               fontString:SetText(REWARD_AURA);
            end
            if (fontString:GetText() == QTR_Messages.reward_spell) then
               fontString:SetFont(Original_Font2, 13);
               fontString:SetJustifyH("LEFT");         -- wyrównanie od lewego
               fontString:SetText(REWARD_SPELL);
            end
            if (fontString:GetText() == QTR_Messages.reward_companion) then
               fontString:SetFont(Original_Font2, 13);
               fontString:SetJustifyH("LEFT");         -- wyrównanie od lewego
               fontString:SetText(REWARD_COMPANION);
            end
            if (fontString:GetText() == QTR_Messages.reward_follower) then
               fontString:SetFont(Original_Font2, 13);
               fontString:SetJustifyH("LEFT");         -- wyrównanie od lewego
               fontString:SetText(REWARD_FOLLOWER);
            end
            if (fontString:GetText() == QTR_Messages.reward_reputation) then
               fontString:SetFont(Original_Font2, 13);
               fontString:SetJustifyH("LEFT");         -- wyrównanie od lewego
               fontString:SetText(REWARD_REPUTATION);
            end
            if (fontString:GetText() == QTR_Messages.reward_title) then
               fontString:SetFont(Original_Font2, 13);
               fontString:SetJustifyH("LEFT");         -- wyrównanie od lewego
               fontString:SetText(REWARD_TITLE);
            end
            if (fontString:GetText() == QTR_Messages.reward_tradeskill) then
               fontString:SetFont(Original_Font2, 13);
               fontString:SetJustifyH("LEFT");         -- wyrównanie od lewego
               fontString:SetText(REWARD_TRADESKILL);
            end
            if (fontString:GetText() == QTR_Messages.reward_unlock) then
               fontString:SetFont(Original_Font2, 13);
               fontString:SetJustifyH("LEFT");         -- wyrównanie od lewego
               fontString:SetText(REWARD_UNLOCK);
            end
            if (fontString:GetText() == QTR_Messages.reward_bonus) then
               fontString:SetFont(Original_Font2, 13);
               fontString:SetJustifyH("LEFT");         -- wyrównanie od lewego
               fontString:SetText(REWARD_BONUS);
            end
         end
      end
      if ( MapQuestInfoRewardsFrame:IsVisible() ) then
         for fontString in MapQuestInfoRewardsFrame.spellHeaderPool:EnumerateActive() do
            if (fontString:GetText() == QTR_Messages.reward_aura) then
               fontString:SetFont(Original_Font2, 11);
               fontString:SetJustifyH("LEFT");         -- wyrównanie od lewego
               fontString:SetText(REWARD_AURA);
            end
            if (fontString:GetText() == QTR_Messages.reward_spell) then
               fontString:SetFont(Original_Font2, 11);
               fontString:SetJustifyH("LEFT");         -- wyrównanie od lewego
               fontString:SetText(REWARD_SPELL);
            end
            if (fontString:GetText() == QTR_Messages.reward_companion) then
               fontString:SetFont(Original_Font2, 11);
               fontString:SetJustifyH("LEFT");         -- wyrównanie od lewego
               fontString:SetText(REWARD_COMPANION);
            end
            if (fontString:GetText() == QTR_Messages.reward_follower) then
               fontString:SetFont(Original_Font2, 11);
               fontString:SetJustifyH("LEFT");         -- wyrównanie od lewego
               fontString:SetText(REWARD_FOLLOWER);
            end
            if (fontString:GetText() == QTR_Messages.reward_reputation) then
               fontString:SetFont(Original_Font2, 11);
               fontString:SetJustifyH("LEFT");         -- wyrównanie od lewego
               fontString:SetText(REWARD_REPUTATION);
            end
            if (fontString:GetText() == QTR_Messages.reward_title) then
               fontString:SetFont(Original_Font2, 11);
               fontString:SetJustifyH("LEFT");         -- wyrównanie od lewego
               fontString:SetText(REWARD_TITLE);
            end
            if (fontString:GetText() == QTR_Messages.reward_tradeskill) then
               fontString:SetFont(Original_Font2, 11);
               fontString:SetJustifyH("LEFT");         -- wyrównanie od lewego
               fontString:SetText(REWARD_TRADESKILL);
            end
            if (fontString:GetText() == QTR_Messages.reward_unlock) then
               fontString:SetFont(Original_Font2, 11);
               fontString:SetJustifyH("LEFT");         -- wyrównanie od lewego
               fontString:SetText(REWARD_UNLOCK);
            end
            if (fontString:GetText() == QTR_Messages.reward_bonus) then
               fontString:SetFont(Original_Font2, 11);
               fontString:SetJustifyH("LEFT");         -- wyrównanie od lewego
               fontString:SetText(REWARD_BONUS);
            end
         end
      end
   end
end


function QTR_delayed3()
   if (not QTR_wait(1,QTR_delayed4)) then
   ---
   end
end


function QTR_delayed4()
   QTR_QuestPrepare('');
end;      


function QTR_PrepareDelay(czas)     -- wywoływane po kliknięciu na nazwę questu z listy NPC
   if (czas==1) then
      if (not QTR_wait(1,QTR_PrepareReload)) then
      ---
      end
   end
   if (czas==3) then
      if (not QTR_wait(3,QTR_PrepareReload)) then
      ---
      end
   end
   if (czas==9) then
      if (not QTR_wait(0.5,QTR_PrepareReload)) then
      ---
      end
   end
end;      


function QTR_PrepareReload()
   QTR_QuestPrepare('');
end;      


-- podmieniaj specjane znaki w tekście
function QTR_ExpandUnitInfo(msg,OnObjectives)
   msg = string.gsub(msg, "NEW_LINE", "#");
   msg = string.gsub(msg, "YOUR_NAME", string.utf8reverse(QTR_name));
   
-- jeszcze obsłużyć YOUR_GENDER(x;y)
   local nr_1, nr_2, nr_3 = 0;
   local QTR_forma = "";
   local nr_poz = string.find(msg, "YOUR_GENDER");    -- gdy nie znalazł, jest: nil
   while (nr_poz and nr_poz>0) do
      nr_1 = nr_poz + 1;   
      while (string.sub(msg, nr_1, nr_1) ~= "(") do
         nr_1 = nr_1 + 1;
      end
      if (string.sub(msg, nr_1, nr_1) == "(") then
         nr_2 =  nr_1 + 1;
         while (string.sub(msg, nr_2, nr_2) ~= ";") do
            nr_2 = nr_2 + 1;
         end
         if (string.sub(msg, nr_2, nr_2) == ";") then
            nr_3 = nr_2 + 1;
            while (string.sub(msg, nr_3, nr_3) ~= ")") do
               nr_3 = nr_3 + 1;
            end
            if (string.sub(msg, nr_3, nr_3) == ")") then
               if (QTR_sex==3) then        -- forma żeńska
                  QTR_forma = string.sub(msg,nr_2+1,nr_3-1);
               else                        -- forma męska
                  QTR_forma = string.sub(msg,nr_1+1,nr_2-1);
               end
               msg = string.sub(msg,1,nr_poz-1) .. QTR_forma .. string.sub(msg,nr_3+1);
            end   
         end
      end
      nr_poz = string.find(msg, "YOUR_GENDER");
   end

-- jeszcze obsłużyć OWN_NAME(EN;AR)    : reversed
   local nr_1, nr_2, nr_3 = 0;
   local QTR_forma = "";
   local nr_poz = string.find(msg, "OWN_NAME");    -- gdy nie znalazł, jest: nil
   while (nr_poz and nr_poz>0) do
      nr_1 = nr_poz + 1;   
      while (string.sub(msg, nr_1, nr_1) ~= "(") do
         nr_1 = nr_1 + 1;
      end
      if (string.sub(msg, nr_1, nr_1) == "(") then
         nr_2 =  nr_1 + 1;
         while (string.sub(msg, nr_2, nr_2) ~= ";") do
            nr_2 = nr_2 + 1;
         end
         if (string.sub(msg, nr_2, nr_2) == ";") then
            nr_3 = nr_2 + 1;
            while (string.sub(msg, nr_3, nr_3) ~= ")") do
               nr_3 = nr_3 + 1;
            end
            if (string.sub(msg, nr_3, nr_3) == ")") then
               if (QTR_PS["ownname"] == "0") then        -- forma angielska
                  QTR_forma = string.sub(msg,nr_2+1,nr_3-1);
               else                        -- forma polska
                  QTR_forma = string.sub(msg,nr_1+1,nr_2-1);
               end
               if ((QTR_PS["ownname_obj"] == "1") and OnObjectives) then        -- zawsze forma angielska w Objectives
                  QTR_forma = string.sub(msg,nr_2+1,nr_3-1);
               end
               msg = string.sub(msg,1,nr_poz-1) .. QTR_forma .. string.sub(msg,nr_3+1);
            end   
         end
      end
      nr_poz = string.find(msg, "OWN_NAME");
   end

   if (QTR_sex==3) then        -- płeć żeńska (female)
      msg = string.gsub(msg, "YOUR_CLASS1", player_class.M2);          -- Mianownik (kto, co?)
      msg = string.gsub(msg, "YOUR_CLASS2", player_class.D2);          -- Dopełniacz (kogo, czego?)
      msg = string.gsub(msg, "YOUR_CLASS4", player_class.B2);          -- Biernik (kogo, co?)
      msg = string.gsub(msg, "YOUR_CLASS", player_class.M2);           -- Mianownik - pozostałe wystąpienia
      msg = string.gsub(msg, "YOUR_RACE1", player_race.M2);            -- Mianownik (kto, co?)
      msg = string.gsub(msg, "YOUR_RACE2", player_race.D2);            -- Dopełniacz (kogo, czego?)
      msg = string.gsub(msg, "YOUR_RACE4", player_race.B2);            -- Biernik (kogo, co?)
      msg = string.gsub(msg, "YOUR_RACE", player_race.M2);             -- Mianownik - pozostałe wystąpienia
   else                    -- płeć męska     (male)
      msg = string.gsub(msg, "YOUR_CLASS1", player_class.M1);          -- Mianownik (kto, co?)
      msg = string.gsub(msg, "YOUR_CLASS2", player_class.D1);          -- Dopełniacz (kogo, czego?)
      msg = string.gsub(msg, "YOUR_CLASS4", player_class.B1);          -- Biernik (kogo, co?)
      msg = string.gsub(msg, "YOUR_CLASS", player_class.M1);           -- Mianownik - pozostałe wystąpienia
      msg = string.gsub(msg, "YOUR_RACE1", player_race.M1);            -- Mianownik (kto, co?)
      msg = string.gsub(msg, "YOUR_RACE2", player_race.D1);            -- Dopełniacz (kogo, czego?)
      msg = string.gsub(msg, "YOUR_RACE4", player_race.B1);            -- Biernik (kogo, co?)
      msg = string.gsub(msg, "YOUR_RACE", player_race.M1);             -- Mianownik - pozostałe wystąpienia
   end
   
   return msg;
end


function QTR_ScrollFrame_OnMouseWheel(self, step)
   local newValue = self:GetVerticalScroll() - (step * 15);
   if (newValue < 0) then
      newValue = 0;
   elseif (newValue > self:GetVerticalScrollRange()) then
      newValue = self:GetVerticalScrollRange();
   end
   self:SetVerticalScroll(newValue);
end



QTR = CreateFrame("Frame");
QTR:SetScript("OnEvent", QTR_OnEvent);
QTR:RegisterEvent("ADDON_LOADED");
QTR:RegisterEvent("QUEST_ACCEPTED");
QTR:RegisterEvent("QUEST_DETAIL");
QTR:RegisterEvent("QUEST_PROGRESS");
QTR:RegisterEvent("QUEST_COMPLETE");
