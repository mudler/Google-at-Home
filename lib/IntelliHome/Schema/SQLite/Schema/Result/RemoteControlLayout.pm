package IntelliHome::Schema::SQLite::Schema::Result::RemoteControlLayout;
use base qw/DBIx::Class::Core/;
 
__PACKAGE__->table('remote_control_layout');
__PACKAGE__->add_columns(
	'rclid' => { data_type=>'int', is_auto_increment=>1 }, 
	'userid' => { data_type=>'int' }, 
	'name' => { accessor => '_check_name' });
__PACKAGE__->set_primary_key('rclid');
__PACKAGE__->belongs_to(user => 'IntelliHome::Schema::SQLite::Schema::Result::User', 'userid');
 

sub check_name (@) {
    my ($self, $value) = @_;
 	
    die "Invalid name format!" if($value =~ /[$-\/:-?{-~!"^_`\[\]]|^$/);
    #TODO convert the string in a standard form
    $self->_check_name($value);
 
    return $self->_check_name();
}

1;
