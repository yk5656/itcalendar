TYPE_ATND       = 1
TYPE_ZUSAAR     = 2
TYPE_CONNPASS   = 3
TYPE_DOORKEEPER = 4

SITE_NAME = {
    TYPE_ATND       => 'ATND',
    TYPE_ZUSAAR     => 'Zusaar',
    TYPE_CONNPASS   => 'connpass',
    TYPE_DOORKEEPER => 'Dookeeper',
}

AREA_HOKKAIDO_TOHOKU = 1
AREA_KANTO           = 2
AREA_CHUBU           = 3
AREA_KANSAI          = 4
AREA_CHUGOKU_SHIKOKU = 5
AREA_KYUSHU_OKINAWA  = 6

AREA_CATEGORIES = {
    AREA_HOKKAIDO_TOHOKU => {
      :action => 'hokkaido_tohoku',
      :name => '北海道・東北',
      :list => {1 => '北海道', 2 => '青森', 3 => '岩手', 4 => '宮城', 5 => '秋田', 6 => '山形', 7 => '福島'},
    },
    AREA_KANTO => {
      :action => 'kanto',
      :name => '関東',
      :list => {13 => '東京', 14 => '神奈川', 11 => '埼玉', 12 => '千葉', 8 => '茨城', 9 => '栃木', 10 => '群馬'},
    },
    AREA_CHUBU => {
      :action => 'chubu',
      :name => '中部',
      :list => {23 => '愛知', 22 => '静岡', 21 => '岐阜', 20 => '長野', 16 => '富山', 17 => '石川', 18 => '福井', 15 => '新潟', 19 => '山梨'}
    },
    AREA_KANSAI => {
      :action => 'kansai',
      :name => '関西',
      :list => {27 => '大阪', 28 => '兵庫', 26 => '京都', 25 => '滋賀', 29 => '奈良', 30 => '和歌山', 24 => '三重'},
    },
    AREA_CHUGOKU_SHIKOKU => {
      :action => 'chugoku_shikoku',
      :name => '中国・四国',
      :list => {34 => '広島', 33 => '岡山', 31 => '鳥取', 32 => '島根', 35 => '山口', 37 => '香川', 38 => '愛媛', 36 => '徳島', 39 => '高知'},
    },
    AREA_KYUSHU_OKINAWA => {
      :action => 'kyushu_okinawa',
      :name => '九州・沖縄',
      :list => {40 => '福岡', 43 => '熊本', 42 => '長崎', 41 => '佐賀', 44 => '大分', 45 => '宮崎', 46 => '鹿児島', 47 => '沖縄'}
    },
}

NG_OWNER_ID = {
    TYPE_ATND       => {
        179961 => true,     #スリーピース交流会 & 社会人サークル｜関東・東京
    },
    TYPE_ZUSAAR     => {
    },
    TYPE_CONNPASS   => {
    },
    TYPE_DOORKEEPER => {
        1888 => true,       #COOK COOP BOK STUDIO
        1055 => true,       #Akakura Baby & Kids Club あかくら
    },
}


MAX_MONTHS  = 2
MAX_EVENTS  = 9999
EXPIRE_SEC  = 1*60
