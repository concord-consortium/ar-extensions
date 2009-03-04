dir = '/Users/blythie/radrails/ar_test/ar_test/vendor'
$: << "#{dir}/rails/activerecord/lib"
ENV["ARE_DB"] = 'mysql'
require File.expand_path( File.join( File.dirname( __FILE__ ), 'test_helper' ) )



class FindersTest < Test::Unit::TestCase
  include ActiveRecord::ConnectionAdapters
  self.fixture_path = File.join( File.dirname( __FILE__ ), 'fixtures/unit/active_record_base_finders' )
  self.fixtures 'books'

  def setup
    @connection = ActiveRecord::Base.connection
  end
  
  def teardown
    Topic.delete_all
    Book.delete_all
  end
  
  def test_find_with_having

    create_books_and_topics
    
    #test having without associations
    books = Book.find(:all, :select => 'count(*) as count_all, topic_id', :group => :topic_id, :having => 'count(*) > 1')
    assert_equal 2, books.size
    
    #test having with associations
    books = Book.find(:all, 
      :include => :topic, 
      :conditions => " topics.id is not null", #the conditions forces eager loading in Rails 2.2
      :select => 'count(*) as count_all, topic_id',
      :group => :topic_id,
      :having => 'count(*) > 1')
      
    assert_equal 2, books.size
    
  end
  
  def test_finder_sql_to_string
    book_sql = Book.finder_sql_to_string(:select => 'topic_id', :include => :topic)
    assert_equal('SELECT topic_id FROM `books`', book_sql)
    
    book_sql = Book.finder_sql_to_string(:select => 'topic_id', :include => :topic, :conditions => 'topics.id is not null')
    assert_equal("SELECT `books`.`id` AS t0_r0, `books`.`title` AS t0_r1, `books`.`publisher` AS t0_r2, `books`.`author_name` AS t0_r3, `books`.`created_at` AS t0_r4, `books`.`created_on` AS t0_r5, `books`.`updated_at` AS t0_r6, `books`.`updated_on` AS t0_r7, `books`.`topic_id` AS t0_r8, `books`.`for_sale` AS t0_r9, `topics`.`id` AS t1_r0, `topics`.`title` AS t1_r1, `topics`.`author_name` AS t1_r2, `topics`.`author_email_address` AS t1_r3, `topics`.`written_on` AS t1_r4, `topics`.`bonus_time` AS t1_r5, `topics`.`last_read` AS t1_r6, `topics`.`content` AS t1_r7, `topics`.`approved` AS t1_r8, `topics`.`replies_count` AS t1_r9, `topics`.`parent_id` AS t1_r10, `topics`.`type` AS t1_r11, `topics`.`created_at` AS t1_r12, `topics`.`updated_at` AS t1_r13 FROM `books`  LEFT OUTER JOIN `topics` ON `topics`.id = `books`.topic_id WHERE (topics.id is not null)", book_sql)
  end
  
  def test_pre_sql
    book_sql = Book.finder_sql_to_string(:select => 'topic_id', :pre_sql => "/* BLAH */")
    assert(/^\/\* BLAH \*\/\sSELECT/.match(book_sql))
    
    book_sql = Book.finder_sql_to_string(:select => 'topic_id', :pre_sql => "/* BLAH */", :include => :topic, :conditions => 'topics.id is not null')
    assert(/^\/\* BLAH \*\/\sSELECT/.match(book_sql))
  end 
  
  def test_post_sql
    book_sql = Book.finder_sql_to_string(:select => 'topic_id', :post_sql => "/* BLAH */")
    assert(/\s\/\* BLAH \*\/$/.match(book_sql))
    
    book_sql = Book.finder_sql_to_string(:select => 'topic_id', :post_sql => "/* BLAH */", :include => :topic, :conditions => 'topics.id is not null')
    assert(/\s\/\* BLAH \*\/$/.match(book_sql))
  end
  
  protected
  
  def create_books_and_topics
    Book.destroy_all
    Topic.destroy_all
    
    topics = [Topic.create!(:title => 'My Topic', :author_name => 'Giraffe'),
              Topic.create!(:title => 'Other Topic', :author_name => 'Giraffe'),
              Topic.create!(:title => 'Last Topic', :author_name => 'Giraffe')]
   
    Book.create!(:title => 'Title A', :topic_id => topics[0].to_param, :author_name => 'Giraffe')
    Book.create!(:title => 'Title B', :topic_id => topics[0].to_param, :author_name => 'Giraffe')
    Book.create!(:title => 'Title C', :topic_id => topics[0].to_param, :author_name => 'Giraffe')
    Book.create!(:title => 'Title D', :topic_id => topics[1].to_param, :author_name => 'Giraffe')
    Book.create!(:title => 'Title E', :topic_id => topics[1].to_param, :author_name => 'Giraffe')
    Book.create!(:title => 'Title F', :topic_id => topics[2].to_param, :author_name => 'Giraffe')
    
  end
end