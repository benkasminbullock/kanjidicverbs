#!/home/ben/software/install/bin/perl
use warnings;
use strict;
use utf8;
use FindBin '$Bin';
use lib "/home/ben/projects/lingua-ja-verb-deinflect/verb-deinflect";
use MakeVerbs ':all';
use Data::Kanji::Kanjidic ':all';
use Lingua::JA::Moji ':all';
my %entries;
my %pos;
my $entry;
my $bad_entry;
my %bad_entries;
binmode STDOUT, ":encoding(utf8)";
read_bad_entries (\%bad_entries);
my $file = '/home/ben/projects/j2e-parser/c-parse-xml/verbs.tmp';

read_entries ($file, \%entries, \%pos, \%bad_entries);
my $k = parse_kanjidic ("/home/ben/data/edrdg/kanjidic");

my $reject = qr!
(?:
あがる
|
にいく
|
があく
|
がある
|
くなる
|
なくなる
|
がつく
|
つける
|
につく
|
にでる
|
にだす
|
にかかる
|
にかける
|
くつく
|
がすわる
|
になる
|
におく
|
による
)$
|
^(?:
食い
|
飲み
|
駆け
|
騙し
|
足が
|
頭
|
雨
|
仇
|
溢れ
|
言い
|
生きて
|
受け
|
打ち
|
追い
|
押し
|
思い
|
書き
|
型に
|
聞き
|
気(?:が|に)
|
切り
|
事が
|
差し
|
誘い
|
旨く
|
丸く
|
乗り
|
付いて
|
使い
|
取り
|
譲り
|
買い
|
走り
|
口
|
食べ
|
訳が
|
読み
|
呼び
|
良く
|
連れて
|
耳に
|
持って
|
手
|
鳴き
|
飛び
|
降り
|
明るみ
|
亡く
|
吹き
|
咲き
|
問い
|
噛み
|
読み
|
当て
|
洗い
|
生き
|
考え
|
行き
|
見|身|胸|腰|腹|肩|目|声|顎|息|藁
|
出て
|
飲ま
|
食わ
|
食ら
|
遊び
|
通り
|
這い
|
踏み
|
語り
|
煙
|
黙り
|
車
|
跳び
|
落ち
|
立ち
|
突き
|
泣き
|
振り
|
抱き
|
待ち
|
引き
|
寄り
|
噛み
|
問い
|
怒り
|
笑い
|
忘れ
|
酔い
|
持ち
|
褒め
|
誉め
|
引っ
|
取っ
|
払い
|
張り
|
遣ら
|
遣り
|
動き
|
包み
|
叩き
|
吐き
|
吸い
|
喋り
|
弱み
|
理に
|
焼き
|
揉み
|
前に
)
!x;

my %done;
for my $key (sort keys %entries) {
    for my $entry (@{$entries{$key}}) {
	my $readings = $entry->{reading};
	my $kanjis = $entry->{kanji};
	if (! $kanjis) {
	    next;
	}
	for my $kanji (@$kanjis) {
	    if ($kanji !~ /^(\p{InCJKUnifiedIdeographs})(\p{InKana}+)$/) {
#		print "Reject $kanji\n";
		next;
	    }
	    if ($kanji =~ $reject) {
		next;
	    }
	    my $firstkanji = $1;
	    my $kdic = $k->{$firstkanji};
	    my $kunyomi = $kdic->{kunyomi};
	    my $known;
	    for my $reading (@$readings) {
		for my $kyom (@$kunyomi) {
		    $reading =~ s/\W//g;
		    $kyom =~ s/\W//g;
		    if ($reading eq $kyom) {
#			print "Known $reading $kyom.\n";
			$known = 1;
		    }
		}
	    }
	    if (! $known) {
		my $out = "$kanji @{$readings}";
		if (! $done{$out}) {
		    print "$out\n";
		}
		$done{$out} = 1;
	    }
	}
    }
}

exit;
