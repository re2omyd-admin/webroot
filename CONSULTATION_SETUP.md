# 상담게시판 최초 1회 설정

GitHub Pages만으로는 DB 저장과 이메일 발송을 할 수 없어 Supabase(게시판/관리자)와 Resend(새 글 이메일 알림) 연결이 필요합니다. 사이트 파일은 이미 준비되어 있으며 아래 설정만 1회 하면 됩니다.

1. Supabase 프로젝트 생성 → SQL Editor에서 `supabase/schema.sql` 전체 실행.
2. Authentication > Users에서 원장님/관리자 로그인 계정 생성. 생성된 user UUID를 확인해 SQL Editor에서 `insert into public.consultation_admins(user_id) values ('USER_UUID');` 실행.
3. Project Settings > API에서 Project URL과 anon public key를 복사하여 `assets/js/consult-config.js`의 두 값에 입력.
4. Supabase CLI 또는 Dashboard에서 `supabase/functions/notify-new-consultation` Edge Function 배포. Secrets에 `RESEND_API_KEY`, `NOTIFY_EMAIL`(새 상담 알림 받을 이메일: `wilbedoc@naver.com`), 필요 시 `FROM_EMAIL` 설정.
5. Database > Webhooks에서 `consultation_questions` INSERT 시 `notify-new-consultation` 함수를 호출하도록 Webhook 생성.
6. `https://re2omyd.com/consultation.html`에서 테스트 질문 등록 → 이메일 수신 확인 → `https://re2omyd.com/admin.html`에서 답변.

가격 관련 키워드가 포함된 질문은 DB에서 `is_price=true`로 자동 표시되고 관리자 화면에서 비공개 답변으로 고정됩니다. 일반 질문은 관리자가 공개/비공개를 선택할 수 있습니다.
## 사진·파일 업로드 정책

이 버전은 **텍스트 상담 전용**입니다. 사진, 이미지, 영상, 문서 등 첨부파일 업로드 기능을 구현하지 않았으며 **Supabase Storage도 사용하지 않습니다.** DB에는 별명, 방문 경로, 사용 AI, 검색 주제, 질문, 답변, 공개/비공개 상태, 작성/답변 시각 등 텍스트 중심 정보만 저장됩니다.

사진 확인이 필요한 상담은 전화 또는 내원 상담으로 안내하는 운영을 권장합니다.

