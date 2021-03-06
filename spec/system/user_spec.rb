require 'rails_helper'
# $ bin/rspec ./spec/system/user_spec.rb

RSpec.describe User, type: :system do
  before(:all) do
    # 15.times {@user = create(:user)}
    15.times { @user = create(:user) do |u|
          u.tasks.create(attributes_for(:task))
        end
      }
    @user = create(:admin_user)
    2.times {@task = create(:admin_task)}
  end
  after(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end

describe '管理者ユーザー'do
  before do # 管理者ユーザーとしてログイン
    visit new_session_path
    fill_in 'session[email]', with: 'admin@test.com'
    fill_in 'session[password]', with: '111111'
    click_on 'commit'
  end

  context 'ログイン画面/sessions/new' do
    it '管理者ユーザーがログインしたら、管理者用のユーザ一覧ページに遷移すること' do
      expect(page).to have_content '管理者権限'
    end
  end

  context 'ユーザー一覧画面/index' do
    it '作成済みのユーザーが表示されること' do
      expect(page).to have_content 'TEST_NAME15'
      expect(page).to_not have_content 'TEST_NAME16'
    end
    it '作成済みのユーザーのタスク数が表示されること' do
      expect(page.all(".tasks_size")[0]).to have_content '1'
      expect(page.all(".tasks_size")[15]).to have_content '2'
    end
  end

  context 'ユーザー作成画面/new' do
    it 'ユーザーが作成されること' do
      visit new_admin_user_path
      fill_in 'user[name]', with: 'new1'
      fill_in 'user[email]', with: 'new1@test.com'
      fill_in 'user[password]', with: '111111'
      fill_in 'user[password_confirmation]', with: '111111'
      click_on 'commit'
      expect(page).to have_content 'new1'
    end

  end

  context 'ユーザー詳細画面/show' do
    it '指定のユーザー情報が表示されること' do
      first(:link, '詳細').click
      expect(page).to have_content '1@test.com'
    end

  end

  context 'ユーザー更新画面/update' do
    it 'ユーザー情報が更新されること' do
            first(:link, '編集').click
            fill_in 'user[name]', with: 'update1111'
            fill_in 'user[email]', with: 'new1@test.com'
            fill_in 'user[password]', with: '111111'
            fill_in 'user[password_confirmation]', with: '111111'
            click_on '編集'
            expect(page).to have_content 'update1111'
    end
    it '管理者権限削除のコールバックが機能すること' do
      visit "/admin/users/16/edit"
      fill_in 'user[name]', with: 'TEST_ADMIN'
      fill_in 'user[email]', with: 'admin@test.com'
      fill_in 'user[password]', with: '111111'
      fill_in 'user[password_confirmation]', with: '111111'
      uncheck 'user[admin]'
      click_on '編集'
      expect(page).to have_content '管理者が１人以上存在する必要があります'
    end
  end

  context 'ユーザー削除画面/destroy' do
    it '一般ユーザーが削除されること' do
      visit "/admin/users/15/"
      first(:link, '退会').click
      page.accept_confirm "本当に削除しますか？"
      expect(page).not_to have_content 'TEST_NAME15'
    end
    it '管理者削除のコールバックが機能すること' do
      visit "/admin/users/16/"
      first(:link, '退会').click
      page.accept_confirm "本当に削除しますか？"
      expect(page).to have_content '管理者ユーザーが１人以上存在する必要があります'
    end
  end
end
describe '一般ユーザー' do
  before do
    visit new_session_path
    fill_in 'session[email]', with: '1@test.com'
    fill_in 'session[password]', with: '111111'
    click_on 'commit'
  end
    it '一般ユーザーがログインしたら、当該ユーザ一の詳細ページに遷移すること' do
      expect(page).to have_content 'TEST_NAME1'
    end
    it '一般ユーザーが管理者ページにアクセスしたら、専用のエラーページに遷移すること' do
      visit admin_users_path
      expect(page).to have_content '403 Forbidden'
    end
    it '一般ユーザーが他のユーザーの詳細ページにアクセスすると、自身のページにredirectされること' do
      visit "/users/10/"
      expect(page).to have_content 'TEST_NAME1'
    end
end
end
