require 'rails_helper'

describe 'posts/show.html.haml' do
  let(:post) { FactoryBot.create(:post, created_by: user) }
  let(:user) { FactoryBot.create(:user, name: 'Jake') }
  let(:tag) { double(:tag, name: 'Rails tag') }

  before do
    allow(view).to receive(:can?).and_return(false)
    allow(post).to receive(:tags).and_return([tag])

    assign(:user, user)
    assign(:post, post)

    stub_template '_comment_feed.html.haml' => ''
    stub_template '_og_header.html.haml' => ''
  end

  it 'sets page title' do
    expect(view).to receive(:set_page_title).with('Why I love Rails')
    render
  end

  it 'displays the post title' do
    render
    expect(rendered).to have_content('Why I love Rails')
  end

  it 'displays a link to the author' do
    render
    expect(rendered).to have_link('Jake', href: user_path(user))
  end

  it 'displays the post content' do
    render
    expect(rendered).to have_content("I love Rails because it's so cool")
  end

  it 'displays each post tag' do
    render
    expect(rendered).to have_content('Rails tag')
  end
end
