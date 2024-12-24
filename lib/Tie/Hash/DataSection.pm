use warnings;
use 5.020;
use experimental qw( signatures );
use stable qw( postderef );
use true;

package Tie::Hash::DataSection {

    # ABSTRACT: Access __DATA__ section via tied hash

    use Data::Section::Pluggable 0.08;
    use Ref::Util qw( is_plain_arrayref );

    sub TIEHASH ($class, $package=undef, @plugins) {
        $package //= caller;
        my $dsp = Data::Section::Pluggable->new(
            package => $package,
        );
        foreach my $plugin (@plugins) {
            if(is_plain_arrayref $plugin) {
                my($name, @args) = @$plugin;
                $dsp->add_plugin($name => @args);
            } else {
                $dsp->add_plugin($plugin);
            }
        }
        return bless [$dsp], $class;
    }

    sub FETCH ($self, $key) {
        return $self->[0]->get_data_section($key);
    }

    sub EXISTS ($self, $key) {
        exists $self->[0]->get_data_section->{$key};
    }

    sub FIRSTKEY ($self) {
        $self->[1] = [keys $self->[0]->get_data_section->%*];
        return $self->NEXTKEY;
    }

    sub NEXTKEY ($self, $=undef) {
        return shift $self->[1]->@*;
    }

    sub STORE ($self, $, $) {
        require Carp;
        Carp::croak("hash is read-only");
    }

    sub DELETE ($self, $) {
        require Carp;
        Carp::croak("hash is read-only");
    }

    sub CLEAR ($self) {
        require Carp;
        Carp::croak("hash is read-only");
    }
}
