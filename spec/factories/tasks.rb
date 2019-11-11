FactoryBot.define do
  factory :task do
    # 下記の内容は実際に作成するカラム名に合わせて変更してください
    sequence(:title) { |n| "TEST_TITLE#{n}"}
    sequence(:content) { |n| "TEST_CONTENT#{n}"}
  end
end