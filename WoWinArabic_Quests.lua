-- Addon: WoWinArabic_Quests (wersja: 10.03) 2023.02.24
-- Note: AddOn displays translated quests in Arabic.
-- الوصف: يتم عرض الترجمة العربية في الإضافة
-- Opis: AddOn wyświetla przetłumaczone questy w języku arabskim.
-- Autor: Platine  (e-mail: platine.wow@gmail.com)
-- Special thanks to DragonArab for helping to create letter reshaping rules.

-- Zmienne lokalne
local QTR_version = GetAddOnMetadata("WoWinArabic_Quests", "Version");
local QTR_limit1 = 35;        -- limit znaków w linii opisującej zadanie w Map&Quest Log
local QTR_limit2 = 32;        -- character limit in the line describing the quest in the conversation with the NPC window
local QTR_limit3 = 18;        -- character limit in the line describing the monster in QuestNPCModelText
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
   ["Blood Elf"] = { M1="بلود إيلف", M2="بلود إيلف" },
   ["Dark Iron Dwarf"] = { M1="دارك ايرون دوارف", M2="دارك ايرون دوارف" },
   ["Dracthyr"] = { M1="دراكثير", M2="دراكثير" },
   ["Draenei"] = { M1="دريناي", M2="دريناي" },
   ["Dwarf"] = { M1="دوارف", M2="دوارف" },
   ["Gnome"] = { M1="قنوم", M2="قنوم" },
   ["Goblin"] = { M1="قوبلن", M2="قوبلن" },
   ["Highmountain Tauren"] = { M1="هايماونتن تورين", M2="هايماونتن تورين" },
   ["Human"] = { M1="بشري", M2="بشري" },
   ["Kul Tiran"] = { M1="كول تيران", M2="كول تيران" },
   ["Lightforged Draenei"] = { M1="لايتفورج دريناي", M2="لايتفورج دريناي" },
   ["Mag'har Orc"] = { M1="ماقهار اورك", M2="ماقهار اورك" },
   ["Mechagnome"] = { M1="ميكاقنوم", M2="ميكاقنوم" },
   ["Nightborne"] = { M1="نايتبرون", M2="نايتبرون" },
   ["Night Elf"] = { M1="نايت إيلف", M2="نايت إيلف" },
   ["Orc"] = { M1="اورك", M2="اورك" },
   ["Pandaren"] = { M1="باندارين", M2="باندارين" },
   ["Tauren"] = { M1="تورين", M2="تورين" },
   ["Troll"] = { M1="ترول", M2="ترول" },
   ["Undead"] = { M1="انديد", M2="انديد" },
   ["Void Elf"] = { M1="فويد إيلف", M2="فويد إيلف" },
   ["Worgen"] = { M1="وارقين", M2="وارقين" },
   ["Zandalari Troll"] = { M1="زندلاري ترول", M2="زندلاري ترول" }
   };

local p_class = {
   ["Death Knight"] = { M1="ديث نايت", M2="ديث نايت" },
   ["Demon Hunter"] = { M1="ديمون هنتر", M2="ديمون هنتر" },
   ["Druid"] = { M1="درود", M2="درود" },
   ["Hunter"] = { M1="هنتر", M2="هنتر" },
   ["Mage"] = { M1="ميج", M2="ميج" },
   ["Monk"] = { M1="مونك", M2="مونك" },
   ["Paladin"] = { M1="بلدين", M2="بلدين" },
   ["Priest"] = { M1="بريست", M2="بريست" },
   ["Rogue"] = { M1="روق", M2="روق" },
   ["Shaman"] = { M1="شامان", M2="شامان" },
   ["Warlock"] = { M1="ورلوك", M2="ورلوك" },
   ["Warrior"] = { M1="وارير", M2="وارير" }
   };

if (p_race[QTR_race]) then      
   player_race = { M1=p_race[QTR_race].M1, M2=p_race[QTR_race].M2 };
else   
   player_race = { M1=QTR_race, M2=QTR_race };
   print ("|cff55ff00QTR - new race: "..QTR_race);
end
if (p_class[QTR_class]) then
   player_class = { M1=p_class[QTR_class].M1, M2=p_class[QTR_class].M2 };
else
   player_class = { M1=QTR_class, M2=QTR_class };
   print ("|cff55ff00QTR - new class: "..QTR_class);
end

-------------------------------------------------------------------------------------------------------

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

-------------------------------------------------------------------------------------------------------

-- Zmienne programowe zapisane na stałe na komputerze
function QTR_CheckVars()
  if (not QTR_PS) then
     QTR_PS = {};
  end
  if (not QTR_SAVED) then
     QTR_SAVED = {};
  end
   -- zapis wersji patcha Wow'a
  QTR_PS["patch"] = GetBuildInfo();    -- zapisz za każdym razem, bo może masz nową wersję gry
  
  -- inicjalizacja: tłumaczenia włączone
  if (not QTR_PS["active"]) then
     QTR_PS["active"] = "1";
  end
  -- inicjalizacja: tłumaczenie tytułu questu włączone
  if (not QTR_PS["transtitle"] ) then
     QTR_PS["transtitle"] = "1";   
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

-------------------------------------------------------------------------------------------------------

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

-------------------------------------------------------------------------------------------------------

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

-------------------------------------------------------------------------------------------------------

function QTR_SetCheckButtonState()
  QTRCheckButton0:SetValue(QTR_PS["active"]=="1");
  QTRCheckButton3:SetValue(QTR_PS["transtitle"]=="1");
  QTRCheckButton5:SetValue(QTR_PS["transfixed"]=="1");
end

-------------------------------------------------------------------------------------------------------

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
  QTROptionsHeader:SetPoint("TOPLEFT", 120, -16);
  QTROptionsHeader:SetText("2023 ﺔﻨﺴﻟ Platine ﺭﻮﻄﻤﻟﺍ".." ("..QTR_base.. ") "..QTR_version.." ﺔﺨﺴﻧ WoWinArabic-Quests ﺔﻓﺎﺿﺇ");
  QTROptionsHeader:SetFont(QTR_Font2, 16);

  local QTRDateOfBase = QTROptions:CreateFontString(nil, "ARTWORK");
  QTRDateOfBase:SetFontObject(GameFontNormalLarge);
  QTRDateOfBase:SetJustifyH("LEFT"); 
  QTRDateOfBase:SetJustifyV("TOP");
  QTRDateOfBase:ClearAllPoints();
  QTRDateOfBase:SetPoint("TOPRIGHT", QTROptionsHeader, "TOPRIGHT", 0, -22);
  QTRDateOfBase:SetText("DragonArab :ﺔﻴﺑﺮﻌﻟﺍ ﺔﻐﻠﻟﺍ ﻞﻴﻜﺸﺗ ﺭﻮﻄﻣ "..QTR_date.." : ﺔﻤﺟﺮﺘﻟﺍ ﺕﺎﻧﺎﻴﺑ ﺓﺪﻋﺎﻗ ﺦﻳﺭﺎﺗ");
  QTRDateOfBase:SetFont(QTR_Font2, 16);

  local QTRCheckButton0 = CreateFrame("CheckButton", "QTRCheckButton0", QTROptions, "SettingsCheckBoxControlTemplate");
  QTRCheckButton0.CheckBox:SetScript("OnClick", function(self) if (QTR_PS["active"]=="1") then QTR_PS["active"]="0" else QTR_PS["active"]="1" end; end);
  QTRCheckButton0.CheckBox:SetPoint("TOPLEFT", QTRDateOfBase, "BOTTOMLEFT", 456, -50);    -- pozycja przycisku CheckBox
  QTRCheckButton0:SetPoint("TOPRIGHT", QTRDateOfBase, "BOTTOMRIGHT", 48, -52);   -- pozycja opisu przycisku CheckBox
  QTRCheckButton0.Text:SetFont(QTR_Font2, 18);
  QTRCheckButton0.Text:SetText(AS_UTF8reverse(QTR_Interface.active));       -- Aktywuj dodatek
  QTRCheckButton0.Text:SetJustifyH("RIGHT");

  local QTROptionsMode1 = QTROptions:CreateFontString(nil, "ARTWORK");
  QTROptionsMode1:SetFontObject(GameFontWhite);
  QTROptionsMode1:SetJustifyH("RIGHT");
  QTROptionsMode1:SetJustifyV("TOP");
  QTROptionsMode1:ClearAllPoints();
  QTROptionsMode1:SetPoint("TOPRIGHT", QTRDateOfBase, "BOTTOMRIGHT", -10, -120);
  QTROptionsMode1:SetFont(QTR_Font2, 18);
  QTROptionsMode1:SetText(":"..AS_UTF8reverse(QTR_Interface.settings));          -- Ustawienia dodatku
  
  local QTRCheckButton3 = CreateFrame("CheckButton", "QTRCheckButton3", QTROptions, "SettingsCheckBoxControlTemplate");
  QTRCheckButton3.CheckBox:SetScript("OnClick", function(self) if (QTR_PS["transtitle"]=="0") then QTR_PS["transtitle"]="1" else QTR_PS["transtitle"]="0" end; end);
  QTRCheckButton3.CheckBox:SetPoint("TOPLEFT", QTRDateOfBase, "BOTTOMLEFT", 456, -160);
  QTRCheckButton3:SetPoint("TOPRIGHT", QTRDateOfBase, "BOTTOMRIGHT", 100, -162);
  QTRCheckButton3.Text:SetFont(QTR_Font2, 18);
  QTRCheckButton3.Text:SetText(AS_UTF8reverse(QTR_Interface.transtitle));   -- Przetłumacz tytuł questu
  QTRCheckButton3.Text:SetJustifyH("RIGHT");

  local QTRCheckButton5 = CreateFrame("CheckButton", "QTRCheckButton5", QTROptions, "SettingsCheckBoxControlTemplate");
  QTRCheckButton5.CheckBox:SetScript("OnClick", function(self) if (QTR_PS["transfixed"]=="1") then QTR_PS["transfixed"]="0" else QTR_PS["transfixed"]="1" end; end);
  QTRCheckButton5.CheckBox:SetPoint("TOPLEFT", QTRCheckButton3.CheckBox, "BOTTOMLEFT", 0, -10);
  QTRCheckButton5:SetPoint("TOPRIGHT", QTRCheckButton3.CheckBox, "BOTTOMRIGHT", 75, -12);
  QTRCheckButton5.Text:SetFont(QTR_Font2, 18);
  QTRCheckButton5.Text:SetText(AS_UTF8reverse(QTR_Interface.transfixed));         -- Przetłumacz stałe elementy zadań: Objectives, Rewards
  QTRCheckButton5.Text:SetJustifyH("RIGHT");
  
  local QTRText0 = QTROptions:CreateFontString(nil, "ARTWORK");
  QTRText0:SetFontObject(GameFontWhite);
  QTRText0:SetJustifyH("LEFT");
  QTRText0:SetJustifyV("TOP");
  QTRText0:ClearAllPoints();
  QTRText0:SetPoint("BOTTOMLEFT", 16, 120);
  QTRText0:SetFont(QTR_Font2, 13);
  QTRText0:SetText("Quick commands from the chat line:");
  
  local QTRText7 = QTROptions:CreateFontString(nil, "ARTWORK");
  QTRText7:SetFontObject(GameFontWhite);
  QTRText7:SetJustifyH("LEFT");
  QTRText7:SetJustifyV("TOP");
  QTRText7:ClearAllPoints();
  QTRText7:SetPoint("TOPLEFT", QTRText0, "BOTTOMLEFT", 0, -10);
  QTRText7:SetFont(QTR_Font2, 13);
  QTRText7:SetText("/qtr   to bring up this addon settings window");
  
  local QTRText1 = QTROptions:CreateFontString(nil, "ARTWORK");
  QTRText1:SetFontObject(GameFontWhite);
  QTRText1:SetJustifyH("LEFT");
  QTRText1:SetJustifyV("TOP");
  QTRText1:ClearAllPoints();
  QTRText1:SetPoint("TOPLEFT", QTRText7, "BOTTOMLEFT", 0, -10);
  QTRText1:SetFont(QTR_Font2, 13);
  QTRText1:SetText("/qtr 1  or  /qtr on   to activate the addon");

  local QTRText2 = QTROptions:CreateFontString(nil, "ARTWORK");
  QTRText2:SetFontObject(GameFontWhite);
  QTRText2:SetJustifyH("LEFT");
  QTRText2:SetJustifyV("TOP");
  QTRText2:ClearAllPoints();
  QTRText2:SetPoint("TOPLEFT", QTRText1, "BOTTOMLEFT", 0, -4);
  QTRText2:SetFont(QTR_Font2, 13);
  QTRText2:SetText("/qtr 0  or  /qtr off   to deactivate the addon");
  
  local QTRText3 = QTROptions:CreateFontString(nil, "ARTWORK");
  QTRText3:SetFontObject(GameFontWhite);
  QTRText3:SetJustifyH("LEFT");
  QTRText3:SetJustifyV("TOP");
  QTRText3:ClearAllPoints();
  QTRText3:SetPoint("TOPLEFT", QTRText2, "BOTTOMLEFT", 0, -4);
  QTRText3:SetFont(QTR_Font2, 13);
  QTRText3:SetText("/qtr title 1  or  /qtr title on   to activate translation of titles");

  local QTRText4 = QTROptions:CreateFontString(nil, "ARTWORK");
  QTRText4:SetFontObject(GameFontWhite);
  QTRText4:SetJustifyH("LEFT");
  QTRText4:SetJustifyV("TOP");
  QTRText4:ClearAllPoints();
  QTRText4:SetPoint("TOPLEFT", QTRText3, "BOTTOMLEFT", 0, -4);
  QTRText4:SetFont(QTR_Font2, 13);
  QTRText4:SetText("/qtr title 0  or  /qtr title off   to deactivate translation of titles");
  
end

-------------------------------------------------------------------------------------------------------

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

-------------------------------------------------------------------------------------------------------

function QTR_ON_OFF()
   if (curr_trans=="1") then
      curr_trans="0";
      QTR_Translate_Off(1);
   else   
      curr_trans="1";
      QTR_Translate_On(1);
   end
end

-------------------------------------------------------------------------------------------------------

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
   
end

-------------------------------------------------------------------------------------------------------

function QTR_QuestLogPopupShow()
   if (QuestLogPopupDetailFrame:IsVisible()) then
      QTR_QuestPrepare("QUEST_DETAIL");
   end
end

-------------------------------------------------------------------------------------------------------

-- Kolejny quest w otwartym już oknie QuestFrame?
function QTR_QuestFrameButton_OnClick()
   if (not QTR_wait(0.5, QTR_QuestFrameWithoutOpenQuestFrame)) then
      -- opóźnienie 0.5 sek
   end
end

-------------------------------------------------------------------------------------------------------

function Spr_Gender(msg)         -- miało być używane w QTR_Messages.itemchoose1 - na razie wyłączone
   local nr_1, nr_2, nr_3 = 0;
   local QTR_forma = "";
   local licznik = 0;
   local nr_poz = string.find(msg, "YOUR_GENDER");    -- gdy nie znalazł - jest: nil; liczy od 1
   while (nr_poz and nr_poz>0) do
      nr_1 = nr_poz + 1;   
      if (string.sub(msg, nr_1, nr_1) ~= "(") then    -- szukaj nawiasu otwierającego, 1 spacja są dopuszczalna
         nr_1 = nr_1 + 1;
      end
      if (string.sub(msg, nr_1, nr_1) == "(") then
         nr_2 =  nr_1 + 1;
         licznik = 0;
         while (string.sub(msg, nr_2, nr_2) ~= ";") do   -- szukaj średnika oddzielającego
            licznik = licznik + 1;
            if (licznik > 50) then
               break;
            else
               nr_2 = nr_2 + 1;
            end
         end
         if (string.sub(msg, nr_2, nr_2) == ";") then
            nr_3 = nr_2 + 1;
            licznik = 0;
            while (string.sub(msg, nr_3, nr_3) ~= ")") do   -- szukaj nawiasu zamykającego
               if (licznik > 50) then
                  break;
               else
                  nr_3 = nr_3 + 1;
               end
            end
            if (string.sub(msg, nr_3, nr_3) == ")") then
               if (QTR_sex==3) then        -- forma żeńska
                  QTR_forma = string.sub(msg,nr_2+1,nr_3-1);
               else                        -- forma męska
                  QTR_forma = string.sub(msg,nr_1+1,nr_2-1);
               end
               msg = string.sub(msg,1,nr_poz-1) .. QTR_forma .. string.sub(msg,nr_3+1);
            else     -- niewłaściwa składnia kodu
               msg = string.gsub(msg, "YOUR_GENDER", "G$");
            end   
         else        -- niewłaściwa składnia kodu
            msg = string.gsub(msg, "YOUR_GENDER", "G$");
         end
      else           -- niewłaściwa składnia kodu
         msg = string.gsub(msg, "YOUR_GENDER", "G$");
      end
      nr_poz = string.find(msg, "YOUR_GENDER");
   end
   return msg;
end

-------------------------------------------------------------------------------------------------------

function QTR_SaveQuest(event)
   if (event=="QUEST_DETAIL") then
      QTR_SAVED[QTR_quest_ID.." TITLE"]=GetTitleText();            -- save original title to future translation
      QTR_SAVED[QTR_quest_ID.." DESCRIPTION"]=GetQuestText();      -- save original text to future translation
      QTR_SAVED[QTR_quest_ID.." OBJECTIVE"]=GetObjectiveText();    -- save original text to future translation
      local QTR_mapID = C_Map.GetBestMapForUnit("player");
      if (QTR_mapID) then
         local QTR_mapINFO = C_Map.GetMapInfo(QTR_mapID);
         QTR_SAVED[QTR_quest_ID.." MAPID"]=QTR_mapID.."@"..QTR_mapINFO.name.."@"..QTR_mapINFO.mapType.."@"..QTR_mapINFO.parentMapID;     -- save mapID to locale place of this quest
      end
   end
   if (event=="QUEST_PROGRESS") then
      QTR_SAVED[QTR_quest_ID.." PROGRESS"]=GetProgressText();      -- save original text to future translation
   end
   if (event=="QUEST_COMPLETE") then
      QTR_SAVED[QTR_quest_ID.." COMPLETE"]=GetRewardText();        -- save original text to future translation
   end
   if (QTR_SAVED[QTR_quest_ID.." TITLE"]==nil) then
      QTR_SAVED[QTR_quest_ID.." TITLE"]=GetTitleText();            -- zapisz tytuł w przypadku tylko Zakończenia
   end
   QTR_SAVED[QTR_quest_ID.." PLAYER"]=QTR_name..'@'..QTR_race..'@'..QTR_class;  -- zapisz dane gracza
end

-------------------------------------------------------------------------------------------------------

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

-------------------------------------------------------------------------------------------------------

-- Wywoływane przy przechwytywanych zdarzeniach
function QTR_OnEvent(self, event, name, ...)
   if (event=="ADDON_LOADED" and name=="WoWinArabic_Quests") then
      QTR_f:UnregisterEvent("ADDON_LOADED");
      local _fontC, _sizeC, _C = DEFAULT_CHAT_FRAME:GetFont(); -- odczytaj aktualną czcionkę, rozmiar i typ
      DEFAULT_CHAT_FRAME:SetFont(QTR_Font2, _sizeC, _C);
      QTR_START();
      SlashCmdList["WOWINARABIC_QUESTS"] = function(msg) QTR_SlashCommand(msg); end
      SLASH_WOWINARABIC_QUESTS1 = "/wowinarabic-quests";
      SLASH_WOWINARABIC_QUESTS2 = "/qtr";
      QTR_CheckVars();
      -- twórz interface Options w Blizzard-Interface-Addons
      QTR_BlizzardOptions();
      print ("|cffffff00WoWinArabic-Quests ver. "..QTR_version.." - "..QTR_Messages.started);
      QTR_f.ADDON_LOADED = nil;
            
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

-------------------------------------------------------------------------------------------------------

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
         QTR_SaveQuest(zdarzenie);
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

-------------------------------------------------------------------------------------------------------

-- wyświetla tłumaczenie
function QTR_Translate_On(typ)
   if (QTR_PS["transfixed"]=="1") then
      QTR_display_constants(1);
   end
--   if (QuestNPCModelText:IsVisible() and (QTR_ModelTextHash>0)) then         -- jest wyświetlony tekst QuestNPCModelText
--      QuestNPCModelText:SetFont(QTR_Font2, 13);
--      QuestNPCModelText:SetJustifyH("RIGHT");         -- wyrównanie od prawego
--      QuestNPCModelText:SetText(QTR_LineReverse(QTR_ModelText_PL,QTR_limit3));   -- tłumaczenie z bazy Gossip
--   end
   
   if (typ==1) then			-- pełne przełączenie (jest tłumaczenie)
      local numer_ID = QTR_quest_ID;
      str_ID = tostring(numer_ID);
      if (numer_ID>0 and QTR_QuestData[str_ID]) then	-- przywróć przetłumaczoną wersję napisów
         QTR_ToggleButton0:SetText("Quest ID="..QTR_quest_ID.." ("..QTR_lang..")");
         QTR_ToggleButton1:SetText("Quest ID="..QTR_quest_ID.." ("..QTR_lang..")");
         QTR_ToggleButton2:SetText("Quest ID="..QTR_quest_ID.." ("..QTR_lang..")");
         if ((QTR_PS["transtitle"]=="1") and QTR_quest_LG[QTR_quest_ID].title) then
            if (WorldMapFrame:IsVisible()) then
               QuestInfoTitleHeader:SetWidth(246);
               QuestProgressTitleText:SetWidth(246);
               QuestInfoObjectivesText:SetWidth(246);
            else
               QuestInfoTitleHeader:SetWidth(276);
               QuestProgressTitleText:SetWidth(276);
               QuestInfoObjectivesText:SetWidth(268);
            end
            QuestInfoTitleHeader:SetFont(QTR_Font1, 18);
            QuestInfoTitleHeader:SetJustifyH("RIGHT");         -- wyrównanie od prawego
            QuestInfoTitleHeader:SetText(AS_UTF8reverse(QTR_quest_LG[QTR_quest_ID].title));
            QuestProgressTitleText:SetFont(QTR_Font1, 15);
            QuestProgressTitleText:SetJustifyH("RIGHT");       -- wyrównanie od prawego
            QuestProgressTitleText:SetText(AS_UTF8reverse(QTR_quest_LG[QTR_quest_ID].title));
         end
         local QTR_limit12 = 50;
         if (WorldMapFrame:IsVisible()) then
            QTR_limit12 = QTR_limit2;
         else
            QTR_limit12 = QTR_limit1;
         end
         QuestInfoDescriptionText:SetFont(QTR_Font2, 14);
         if (QTR_quest_LG[QTR_quest_ID].details) then
            QuestInfoDescriptionText:SetJustifyH("RIGHT");        -- wyrównanie od prawego
            QuestInfoDescriptionText:SetText(QTR_LineReverse(QTR_quest_LG[QTR_quest_ID].details, QTR_limit12));
         else
            QuestInfoDescriptionText:SetText(QTR_Messages.missing);
         end
         QuestInfoObjectivesText:SetFont(QTR_Font2, 14);
         if (QTR_quest_LG[QTR_quest_ID].objectives) then
            QuestInfoObjectivesText:SetJustifyH("RIGHT");         -- wyrównanie od prawego
            QuestInfoObjectivesText:SetText(QTR_LineReverse(QTR_quest_LG[QTR_quest_ID].objectives, QTR_limit12));
         else
            QuestInfoObjectivesText:SetText(QTR_Messages.missing);
         end
         QuestProgressText:SetFont(QTR_Font2, 14);
         if (QTR_quest_LG[QTR_quest_ID].progress) then
            QuestProgressText:SetJustifyH("RIGHT");               -- wyrównanie od prawego
            QuestProgressText:SetText(QTR_LineReverse(QTR_quest_LG[QTR_quest_ID].progress, QTR_limit12));
         else
--            QuestProgressText:SetJustifyH("LEFT");               -- wyrównanie od lewego
            QuestProgressText:SetText(QTR_Messages.missing);
         end
         QuestInfoRewardText:SetWidth(276);
         QuestInfoRewardText:SetFont(QTR_Font2, 14);
         if (QTR_quest_LG[QTR_quest_ID].completion) then
            QuestInfoRewardText:SetJustifyH("RIGHT");             -- wyrównanie od prawego
            QuestInfoRewardText:SetText(QTR_LineReverse(QTR_quest_LG[QTR_quest_ID].completion, QTR_limit12));
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

-------------------------------------------------------------------------------------------------------

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

-------------------------------------------------------------------------------------------------------

function QTR_display_constants(lg)
   if (lg==1) then        -- dane stałe po arabsku
      QuestInfoObjectivesHeader:SetFont(QTR_Font1, 18);
      QuestInfoObjectivesHeader:SetWidth(270);
      QuestInfoObjectivesHeader:SetJustifyH("RIGHT");             -- wyrównanie do prawego
      QuestInfoObjectivesHeader:SetText(AS_UTF8reverse(QTR_Messages.objectives));
      QuestInfoRewardsFrame.Header:SetFont(QTR_Font1, 18);
      QuestInfoRewardsFrame.Header:SetWidth(270);
      QuestInfoRewardsFrame.Header:SetJustifyH("RIGHT");          -- wyrównanie do prawego
      QuestInfoRewardsFrame.Header:SetText(AS_UTF8reverse(QTR_Messages.rewards));
      QuestInfoDescriptionHeader:SetFont(QTR_Font1, 18);
      QuestInfoDescriptionHeader:SetWidth(243);
      QuestInfoDescriptionHeader:SetJustifyH("RIGHT");            -- wyrównanie do prawego
      QuestInfoDescriptionHeader:SetText(AS_UTF8reverse(QTR_Messages.details));
      QuestProgressRequiredItemsText:SetFont(QTR_Font1, 18);
      QuestProgressRequiredItemsText:SetWidth(272);
      QuestProgressRequiredItemsText:SetJustifyH("RIGHT");        -- wyrównanie od prawego
      QuestProgressRequiredItemsText:SetText(AS_UTF8reverse(QTR_Messages.reqitems));
      CurrentQuestsText:SetWidth(270);
      CurrentQuestsText:SetFont(QTR_Font1, 18);
      CurrentQuestsText:SetJustifyH("RIGHT");                     -- wyrównanie od prawego
      CurrentQuestsText:SetText(AS_UTF8reverse(QTR_Messages.currquests));
      AvailableQuestsText:SetWidth(270);
      AvailableQuestsText:SetFont(QTR_Font1, 18);
      AvailableQuestsText:SetJustifyH("RIGHT");                   -- wyrównanie od prawego
      AvailableQuestsText:SetText(AS_UTF8reverse(QTR_Messages.avaiquests));
      local regions = { QuestMapFrame.DetailsFrame.RewardsFrame:GetRegions() };
      for index = 1, #regions do
         local region = regions[index];
         if ((region:GetObjectType() == "FontString") and (region:GetText() == QUEST_REWARDS)) then
            local _font1, _size1, _3 = region:GetFont();    -- odczytaj aktualną czcionkę i rozmiar
            region:SetFont(QTR_Font1, _size1);
            region:SetJustifyH("RIGHT");                          -- wyrównanie od prawego
            region:SetText(AS_UTF8reverse(QTR_Messages.rewards));
         end
      end
      
      -- stałe elementy okna zadania:
      QuestInfoRewardsFrame.ItemChooseText:SetFont(QTR_Font2, 18);
      QuestInfoRewardsFrame.ItemChooseText:SetWidth(270);
      QuestInfoRewardsFrame.ItemChooseText:SetJustifyH("RIGHT");                  -- wyrównanie od prawego
      QuestInfoRewardsFrame.ItemChooseText:SetText(AS_UTF8reverse(QTR_quest_LG[QTR_quest_ID].itemchoose));
      
      QuestInfoRewardsFrame.ItemReceiveText:SetText(" ");
      QuestInfoRewardsFrame.XPFrame.ReceiveText:SetText(" ");
      QuestInfoXPFrame.ReceiveText:SetText(" ");
      
      -- własne obiekty z tekstami arabskimi
      if (not QTR_QuestDetail_ItemReceiveText) then
         QTR_QuestDetail_ItemReceiveText = QuestDetailScrollChildFrame:CreateFontString(nil, "ARTWORK");
         QTR_QuestDetail_ItemReceiveText:SetFontObject(GameFontBlack);
         QTR_QuestDetail_ItemReceiveText:SetJustifyH("RIGHT"); 
         QTR_QuestDetail_ItemReceiveText:SetJustifyV("TOP");
         QTR_QuestDetail_ItemReceiveText:ClearAllPoints();
         QTR_QuestDetail_ItemReceiveText:SetPoint("TOPRIGHT", QuestInfoRewardsFrame.ItemReceiveText, "TOPLEFT", 270, 2);
         QTR_QuestDetail_ItemReceiveText:SetFont(QTR_Font2, 18);
      end
      if (QTR_quest_LG[QTR_quest_ID].itemreceive) then
         QTR_QuestDetail_ItemReceiveText:SetText(AS_UTF8reverse(QTR_quest_LG[QTR_quest_ID].itemreceive));
      else
         QTR_QuestDetail_ItemReceiveText:SetText(AS_UTF8reverse(QTR_Messages.itemreceiv0));
      end
      QTR_QuestDetail_ItemReceiveText:Show();
      if (not QTR_QuestReward_ItemReceiveText) then
         QTR_QuestReward_ItemReceiveText = QuestRewardScrollChildFrame:CreateFontString(nil, "ARTWORK");
         QTR_QuestReward_ItemReceiveText:SetFontObject(GameFontBlack);
         QTR_QuestReward_ItemReceiveText:SetJustifyH("RIGHT"); 
         QTR_QuestReward_ItemReceiveText:SetJustifyV("TOP");
         QTR_QuestReward_ItemReceiveText:ClearAllPoints();
         QTR_QuestReward_ItemReceiveText:SetPoint("TOPRIGHT", QuestInfoRewardsFrame.ItemReceiveText, "TOPLEFT", 270, 2);
         QTR_QuestReward_ItemReceiveText:SetFont(QTR_Font2, 18);
      end
      if (QTR_quest_LG[QTR_quest_ID].itemreceive) then
         QTR_QuestReward_ItemReceiveText:SetText(AS_UTF8reverse(QTR_quest_LG[QTR_quest_ID].itemreceive));
      else
         QTR_QuestReward_ItemReceiveText:SetText(AS_UTF8reverse(QTR_Messages.itemreceiv0));
      end
      if (not QTR_QuestDetail_InfoXP) then
         QTR_QuestDetail_InfoXP = QuestDetailScrollChildFrame:CreateFontString(nil, "ARTWORK");
         QTR_QuestDetail_InfoXP:SetFontObject(GameFontBlack);
         QTR_QuestDetail_InfoXP:SetJustifyH("RIGHT"); 
         QTR_QuestDetail_InfoXP:SetJustifyV("TOP");
         QTR_QuestDetail_InfoXP:ClearAllPoints();
         QTR_QuestDetail_InfoXP:SetPoint("TOPRIGHT", QuestInfoRewardsFrame.XPFrame.ReceiveText, "TOPLEFT", 270, 2);
         QTR_QuestDetail_InfoXP:SetFont(QTR_Font2, 18);
      end
      QTR_QuestDetail_InfoXP:SetText(AS_UTF8reverse(QTR_Messages.experience));
      if (not QTR_QuestReward_InfoXP) then
         QTR_QuestReward_InfoXP = QuestRewardScrollChildFrame:CreateFontString(nil, "ARTWORK");
         QTR_QuestReward_InfoXP:SetFontObject(GameFontBlack);
         QTR_QuestReward_InfoXP:SetJustifyH("RIGHT"); 
         QTR_QuestReward_InfoXP:SetJustifyV("TOP");
         QTR_QuestReward_InfoXP:ClearAllPoints();
         QTR_QuestReward_InfoXP:SetPoint("TOPRIGHT", QuestInfoRewardsFrame.XPFrame.ReceiveText, "TOPLEFT", 270, 2);
         QTR_QuestReward_InfoXP:SetFont(QTR_Font2, 18);
      end
      QTR_QuestReward_InfoXP:SetText(AS_UTF8reverse(QTR_Messages.experience));
      
      QTR_QuestDetail_ItemReceiveText:Show();
      QTR_QuestReward_ItemReceiveText:Show();
      QTR_QuestDetail_InfoXP:Show();
      QTR_QuestReward_InfoXP:Show();
      
      if (QuestInfoMoneyFrame:IsVisible()) then
         QuestInfoXPFrame.ValueText:ClearAllPoints();
         QuestInfoXPFrame.ValueText:SetPoint("TOPRIGHT", QuestInfoMoneyFrame, "BOTTOMRIGHT", -10, 0);
      end
      
      local max_len = AS_UTF8len(QTR_QuestDetail_ItemReceiveText:GetText());
      local money_len = QuestInfoMoneyFrame:GetWidth();
      local spaces05 = "     ";
      local spaces10 = "          ";
      local spaces15 = "               ";
      local spaces20 = "                    ";
--print(max_len,money_len)      
      if (max_len < 10) then
         if (money_len < 70) then
            QuestInfoRewardsFrame.ItemReceiveText:SetText(spaces20);
            QuestInfoRewardsFrame.XPFrame.ReceiveText:SetText(spaces20);
            QuestInfoXPFrame.ReceiveText:SetText(spaces20);
         elseif (money_len < 90) then
            QuestInfoRewardsFrame.ItemReceiveText:SetText(spaces15);
            QuestInfoRewardsFrame.XPFrame.ReceiveText:SetText(spaces15);
            QuestInfoXPFrame.ReceiveText:SetText(spaces15);
         elseif (money_len < 110) then
            QuestInfoRewardsFrame.ItemReceiveText:SetText(spaces10);
            QuestInfoRewardsFrame.XPFrame.ReceiveText:SetText(spaces10);
            QuestInfoXPFrame.ReceiveText:SetText(spaces10);
         elseif (money_len < 130) then
            QuestInfoRewardsFrame.ItemReceiveText:SetText(spaces05);
            QuestInfoRewardsFrame.XPFrame.ReceiveText:SetText(spaces05);
            QuestInfoXPFrame.ReceiveText:SetText(spaces05);
         end
      elseif (max_len <20) then
         if (money_len < 70) then
            QuestInfoRewardsFrame.ItemReceiveText:SetText(spaces15);
            QuestInfoRewardsFrame.XPFrame.ReceiveText:SetText(spaces15);
            QuestInfoXPFrame.ReceiveText:SetText(spaces15);
         elseif (money_len < 90) then
            QuestInfoRewardsFrame.ItemReceiveText:SetText(spaces10);
            QuestInfoRewardsFrame.XPFrame.ReceiveText:SetText(spaces10);
            QuestInfoXPFrame.ReceiveText:SetText(spaces15);
         elseif (money_len < 110) then
            QuestInfoRewardsFrame.ItemReceiveText:SetText(spaces05);
            QuestInfoRewardsFrame.XPFrame.ReceiveText:SetText(spaces05);
            QuestInfoXPFrame.ReceiveText:SetText(spaces05);
         end      
      end
      
      QuestInfoSpellObjectiveLearnLabel:SetFont(QTR_Font2, 13);
      QuestInfoSpellObjectiveLearnLabel:SetJustifyH("LEFT");                     -- wyrównanie od prawego
      QuestInfoSpellObjectiveLearnLabel:SetText(AS_UTF8reverse(QTR_Messages.learnspell));
      MapQuestInfoRewardsFrame.ItemChooseText:SetFont(QTR_Font2, 16);
      local line_size = MapQuestInfoRewardsFrame.ItemChooseText:GetWidth();
      MapQuestInfoRewardsFrame.ItemChooseText:SetJustifyH("RIGHT");               -- wyrównanie do prawego
      MapQuestInfoRewardsFrame.ItemChooseText:SetText(AS_UTF8reverse(QTR_quest_LG[QTR_quest_ID].itemchoose));
      MapQuestInfoRewardsFrame.ItemReceiveText:SetFont(QTR_Font2, 13);
      MapQuestInfoRewardsFrame.ItemReceiveText:SetWidth(line_size);
      MapQuestInfoRewardsFrame.ItemReceiveText:SetJustifyH("RIGHT");              -- wyrównanie do prawego
      MapQuestInfoRewardsFrame.ItemReceiveText:SetText(AS_UTF8reverse(QTR_quest_LG[QTR_quest_ID].itemreceive));
      QuestInfoRewardsFrame.PlayerTitleText:SetFont(QTR_Font2, 13);
      QuestInfoRewardsFrame.PlayerTitleText:SetJustifyH("LEFT");                 -- wyrównanie od prawego
      QuestInfoRewardsFrame.PlayerTitleText:SetText(AS_UTF8reverse(QTR_Messages.reward_title));
      QuestInfoRewardsFrame.QuestSessionBonusReward:SetFont(QTR_Font2, 13);
      QuestInfoRewardsFrame.QuestSessionBonusReward:SetJustifyH("LEFT");         -- wyrównanie od prawego
      QuestInfoRewardsFrame.QuestSessionBonusReward:SetText(AS_UTF8reverse(QTR_Messages.reward_bonus));
      if ( QuestInfoRewardsFrame:IsVisible() ) then
         for fontString in QuestInfoRewardsFrame.spellHeaderPool:EnumerateActive() do
            if (fontString:GetText() == REWARD_AURA) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("LEFT");         -- wyrównanie od prawego
               fontString:SetText(AS_UTF8reverse(QTR_Messages.reward_aura));
            end
            if (fontString:GetText() == REWARD_SPELL) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(AS_UTF8reverse(QTR_Messages.reward_spell));
            end
            if (fontString:GetText() == REWARD_COMPANION) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(AS_UTF8reverse(QTR_Messages.reward_companion));
            end
            if (fontString:GetText() == REWARD_FOLLOWER) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(AS_UTF8reverse(QTR_Messages.reward_follower));
            end
            if (fontString:GetText() == REWARD_REPUTATION) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(AS_UTF8reverse(QTR_Messages.reward_reputation));
            end
            if (fontString:GetText() == REWARD_TITLE) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(AS_UTF8reverse(QTR_Messages.reward_title));
            end
            if (fontString:GetText() == REWARD_TRADESKILL) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(AS_UTF8reverse(QTR_Messages.reward_tradeskill));
            end
            if (fontString:GetText() == REWARD_UNLOCK) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(AS_UTF8reverse(QTR_Messages.reward_unlock));
            end
            if (fontString:GetText() == REWARD_BONUS) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(AS_UTF8reverse(QTR_Messages.reward_bonus));
            end
         end
      end
      if ( MapQuestInfoRewardsFrame:IsVisible() ) then
         for fontString in MapQuestInfoRewardsFrame.spellHeaderPool:EnumerateActive() do
            if (fontString:GetText() == REWARD_AURA) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(AS_UTF8reverse(QTR_Messages.reward_aura));
            end
            if (fontString:GetText() == REWARD_SPELL) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(AS_UTF8reverse(QTR_Messages.reward_spell));
            end
            if (fontString:GetText() == REWARD_COMPANION) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(AS_UTF8reverse(QTR_Messages.reward_companion));
            end
            if (fontString:GetText() == REWARD_FOLLOWER) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(AS_UTF8reverse(QTR_Messages.reward_follower));
            end
            if (fontString:GetText() == REWARD_REPUTATION) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(AS_UTF8reverse(QTR_Messages.reward_reputation));
            end
            if (fontString:GetText() == REWARD_TITLE) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(AS_UTF8reverse(QTR_Messages.reward_title));
            end
            if (fontString:GetText() == REWARD_TRADESKILL) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(AS_UTF8reverse(QTR_Messages.reward_tradeskill));
            end
            if (fontString:GetText() == REWARD_UNLOCK) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(AS_UTF8reverse(QTR_Messages.reward_unlock));
            end
            if (fontString:GetText() == REWARD_BONUS) then
               fontString:SetFont(QTR_Font2, 13);
               fontString:SetJustifyH("RIGHT");         -- wyrównanie od prawego
               fontString:SetText(AS_UTF8reverse(QTR_Messages.reward_bonus));
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
      
      QTR_QuestDetail_ItemReceiveText:Hide();
      QTR_QuestReward_ItemReceiveText:Hide();
      QTR_QuestDetail_InfoXP:Hide();
      QTR_QuestReward_InfoXP:Hide();
      
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
--      QuestInfoXPFrame.ReceiveText:SetJustifyH("LEFT");         -- wyrównanie od lewego / nie zmieniam tego parametru
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

-------------------------------------------------------------------------------------------------------

function QTR_delayed3()
   if (not QTR_wait(1,QTR_delayed4)) then
   ---
   end
end

-------------------------------------------------------------------------------------------------------

function QTR_delayed4()
   QTR_QuestPrepare('');
end;      

-------------------------------------------------------------------------------------------------------

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

-------------------------------------------------------------------------------------------------------

-- podmieniaj specjane znaki w tekście
function QTR_ExpandUnitInfo(msg,OnObjectives)
   msg = string.gsub(msg, "NEW_LINE", "#");
   msg = string.gsub(msg, "YOUR_NAME", AS_UTF8reverse(QTR_name));
   
-- jeszcze obsłużyć YOUR_GENDER(x;y)
   local nr_1, nr_2, nr_3 = 0;
   local QTR_forma = "";
   local nr_poz = string.find(msg, "YOUR_GENDER");    -- gdy nie znalazł, jest: nil
   while (nr_poz and nr_poz>0) do
      nr_1 = nr_poz + 1;   
      if (string.sub(msg, nr_1, nr_1) ~= "(") then    -- dopuszczam 1 spację odstępu
         nr_1 = nr_1 + 1;
      end
      if (string.sub(msg, nr_1, nr_1) == "(") then
         nr_2 =  nr_1 + 1;
         while ((string.sub(msg, nr_2, nr_2) ~= ";") and (nr_1+50>nr_2)) do
            nr_2 = nr_2 + 1;
         end
         if (string.sub(msg, nr_2, nr_2) == ";") then
            nr_3 = nr_2 + 1;
            while ((string.sub(msg, nr_3, nr_3) ~= ")") and (nr_2+50>nr_3)) do
               nr_3 = nr_3 + 1;
            end
            if (string.sub(msg, nr_3, nr_3) == ")") then
               if (QTR_sex==3) then        -- forma żeńska
                  QTR_forma = string.sub(msg,nr_2+1,nr_3-1);
               else                        -- forma męska
                  QTR_forma = string.sub(msg,nr_1+1,nr_2-1);
               end
               msg = string.sub(msg,1,nr_poz-1) .. QTR_forma .. string.sub(msg,nr_3+1);
            else   
               msg = string.gsub(msg, "YOUR_GENDER", "G$");
            end   
         else   
            msg = string.gsub(msg, "YOUR_GENDER", "G$");
         end
      else   
         msg = string.gsub(msg, "YOUR_GENDER", "G$");
      end
      nr_poz = string.find(msg, "YOUR_GENDER");
   end

   if (QTR_sex==3) then        -- płeć żeńska (female)
      msg = string.gsub(msg, "YOUR_CLASS", player_class.M2);        
      msg = string.gsub(msg, "YOUR_RACE", player_race.M2);          
   else                    -- płeć męska     (male)
      msg = string.gsub(msg, "YOUR_CLASS", player_class.M1);      
      msg = string.gsub(msg, "YOUR_RACE", player_race.M1);          
   end
   
   return msg;
end

-------------------------------------------------------------------------------------------------------

local function QTR_ScrollFrame_OnMouseWheel(self, step)
   local newValue = self:GetVerticalScroll() - (step * 15);
   if (newValue < 0) then
      newValue = 0;
   elseif (newValue > self:GetVerticalScrollRange()) then
      newValue = self:GetVerticalScrollRange();
   end
   self:SetVerticalScroll(newValue);
end

-------------------------------------------------------------------------------------------------------

-- Reverses the order of UTF-8 letters in lines of 35 or 32 characters (limit)
function QTR_LineReverse(s, limit)
   local retstr = "";
   if (s and limit) then                           -- check if arguments are not empty (nil)
		local bytes = strlen(s);
		local pos = 1;
		local charbytes;
		local newstr = "";
      local counter = 0;
      local char1;
		while pos <= bytes do
			c = strbyte(s, pos);                      -- read the character (odczytaj znak)
			charbytes = AS_UTF8charbytes(s, pos);    -- count of bytes (liczba bajtów znaku)
         char1 = strsub(s, pos, pos + charbytes - 1);
			newstr = newstr .. char1;
			pos = pos + charbytes;
         
         counter = counter + 1;
         if ((char1 >= "A") and (char1 <= "z")) then
            counter = counter + 1;        -- latin letters are 2x wider, then Arabic
         end
         if ((char1 == "#") or ((char1 == " ") and (counter > limit))) then
            newstr = string.gsub(newstr, "#", "");
            retstr = retstr .. AS_UTF8reverse(newstr) .. "\n";
            newstr = "";
            counter = 0;
         end
      end
      retstr = retstr .. AS_UTF8reverse(newstr);
      retstr = string.gsub(retstr, "#", "");
      retstr = string.gsub(retstr, "\n ", "\n");        -- space after newline code is useless
      retstr = string.gsub(retstr, "\n\n\n", "\n\n");   -- elimination of redundant newline codes
   end
	return retstr;
end 

-------------------------------------------------------------------------------------------------------

QTR_f = CreateFrame("Frame");
QTR_f:SetScript("OnEvent", QTR_OnEvent);
QTR_f:RegisterEvent("ADDON_LOADED");
QTR_f:RegisterEvent("QUEST_ACCEPTED");
QTR_f:RegisterEvent("QUEST_DETAIL");
QTR_f:RegisterEvent("QUEST_PROGRESS");
QTR_f:RegisterEvent("QUEST_COMPLETE");
