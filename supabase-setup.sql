-- ============================================================
--  聖地巡礼マップ / 共有モード セットアップ
--  Supabase の SQL Editor にこのファイルの中身を全部貼り付けて Run
-- ============================================================

-- 1) テーブル
create table if not exists public.spots (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),
  name        text not null,
  work        text,
  addr        text,
  memo        text,
  lat         double precision not null,
  lng         double precision not null,
  author      text,
  edit_token  text not null
);

create index if not exists spots_created_at_idx on public.spots (created_at desc);

-- 2) 行レベルセキュリティ：誰でも「閲覧」と「登録」はできる。書き換え・削除は不可。
alter table public.spots enable row level security;

drop policy if exists "spots_select_all" on public.spots;
create policy "spots_select_all"
  on public.spots for select
  to anon, authenticated
  using (true);

drop policy if exists "spots_insert_all" on public.spots;
create policy "spots_insert_all"
  on public.spots for insert
  to anon, authenticated
  with check (
    length(coalesce(name, '')) between 1 and 80
    and length(coalesce(work, '')) <= 120
    and length(coalesce(addr, '')) <= 200
    and length(coalesce(memo, '')) <= 1000
    and length(coalesce(author, '')) <= 40
    and lat between -90 and 90
    and lng between -180 and 180
    and length(edit_token) between 10 and 80
  );

-- 3) edit_token は他人から読めないようにする（自分の投稿だけ消せる仕組みの鍵）
revoke select (edit_token) on public.spots from anon, authenticated;

-- 4) 自分が登録した聖地だけを削除できる関数
create or replace function public.delete_spot(p_id uuid, p_token text)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  n integer;
begin
  delete from public.spots where id = p_id and edit_token = p_token;
  get diagnostics n = row_count;
  return n > 0;
end;
$$;

grant execute on function public.delete_spot(uuid, text) to anon, authenticated;

-- ============================================================
-- 5) デフォルトの聖地（最初から入っている12件）
--    不要なものは行ごと消してから Run してください
-- ============================================================
insert into public.spots (name, work, addr, memo, lat, lng, author, edit_token) values
('青山剛昌ふるさと館', '原作／作者ゆかりの地', '鳥取県東伯郡北栄町由良宿', '作者・青山剛昌先生の記念館。周辺一帯がコナンの町として整備されている。', 35.48575, 133.78108, 'デフォルト', 'seed-default-0001'),
('コナン駅（JR由良駅）', '原作／作者ゆかりの地', '鳥取県東伯郡北栄町由良宿', '愛称「コナン駅」。ここからコナン通りが伸び、道沿いにブロンズ像が並ぶ。', 35.49022, 133.77873, 'デフォルト', 'seed-default-0002'),
('コナン通り', '原作／作者ゆかりの地', '鳥取県東伯郡北栄町由良宿', '由良駅からふるさと館まで続く道。キャラクターの銅像やオブジェが点在。', 35.48800, 133.77950, 'デフォルト', 'seed-default-0003'),
('東京ドームシティ（後楽園ゆうえんち）', '原作1巻／TV第1話ほか', '東京都文京区後楽1丁目', '新一がコナンになったトロピカルランドのモデルとされる遊園地。', 35.70560, 139.75190, 'デフォルト', 'seed-default-0004'),
('東京スカイツリー', '劇場版『異次元の狙撃手』ほか', '東京都墨田区押上1丁目', '作中の「ベルツリータワー」のモデルとされる。', 35.71006, 139.81069, 'デフォルト', 'seed-default-0005'),
('五稜郭', '劇場版『100万ドルの五稜星』', '北海道函館市五稜郭町', '作品タイトルにもなった舞台。', 41.79693, 140.75690, 'デフォルト', 'seed-default-0006'),
('名古屋城', '劇場版『緋色の弾丸』', '愛知県名古屋市中区本丸', '名古屋が主要舞台のひとつ。', 35.18528, 136.89972, 'デフォルト', 'seed-default-0007'),
('清水寺', '劇場版『迷宮の十字路』', '京都府京都市東山区清水1丁目', '京都が舞台。作中に登場する寺社のひとつ。', 34.99485, 135.78504, 'デフォルト', 'seed-default-0008'),
('大阪城', '劇場版『世紀末の魔術師』', '大阪府大阪市中央区大阪城', '大阪が舞台となる回の定番スポット。', 34.68735, 135.52623, 'デフォルト', 'seed-default-0009'),
('渋谷スクランブル交差点', '劇場版『ハロウィンの花嫁』', '東京都渋谷区道玄坂2丁目', '渋谷のハロウィンが描かれた作品の舞台。', 35.65950, 139.70050, 'デフォルト', 'seed-default-0010'),
('近江神宮', '劇場版『から紅の恋歌』', '滋賀県大津市神宮町', 'かるたの聖地としても知られる。', 35.01965, 135.84790, 'デフォルト', 'seed-default-0011'),
('東京タワー', '劇場版ほか', '東京都港区芝公園4丁目', '複数の作品で東京のランドマークとして登場。', 35.65858, 139.74544, 'デフォルト', 'seed-default-0012');

-- 完了。Settings → API から Project URL と anon public key をコピーして
-- index.html の先頭にある SUPABASE_URL / SUPABASE_ANON_KEY に貼り付けてください。
