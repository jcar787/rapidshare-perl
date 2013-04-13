# Author: Jeffrey Cartagena
# rapidshare.pm
# This is script for download links of rapidshare using the module
# WWW::Mechanize. You have to first create a file with all the links
# of rapidshare one per line. 

package rapidshare;

use strict;
use WWW::Mechanize;
use Time::HiRes "sleep";
use Cwd "abs_path";

# Constructor of the module
sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self = {};
	
	$self->{file} = undef; # Name of the textfile
	$self->{speed} = undef;# Speed of the connection
	$self->{user} = undef; # Username of rapidshare
	$self->{pass} = undef; # Password of rapidshare 
	$self->{type} = undef; # Type of compression zip, rar, 7z
	$self->{queue} = [];	 # Queue for failed links
	$self->{links} = [];	 # Links to be downloaded
	$self->{filenames} = []; # Filenames if the file have more than 1 part

	bless ($self, $class);
	return $self;	
}

# Set and get the name of the file where are the links
sub file {
	my $self = shift;
	$self->{file} = shift if(@_);
	return $self->{file};
}

# Set and get the type of the compression tool
sub type {
	my $self = shift;
	my @type = split/\./, ${$self->{filenames}}[0];
	
	if($type[-1] =~ m#7z#){
		$self->{type} = "7z";
	}
	elsif($type[-1] =~ m#rar#){
		$self->{type} = "rar";
	}
	elsif($type[-1] =~ m#zip#){
		$self->{type} = "zip";
	}
	else {
	$self->{type} = "none";
	}
	return $self->{type};
}


# Read the rapidshare links
sub read {
	my $self = shift;
	open LINKS, $self->{file} or die "Cannot open file $self->{file} $!\n";
	@{$self->{links}} = <LINKS>;
	close LINKS;
	return @{$self->{links}};
}

# Set or get the filename
sub filename {
	my $self = shift;
	foreach (@{$self->{links}}) {
		my @chunks = split/\//;
		chomp($chunks[-1]);
		$chunks[-1] =~ s#.html##;
		push(@{$self->{filenames}}, $chunks[-1]);
	}
	return @{$self->{filenames}};
}

# Start downloading the links
sub startdownload {
	my $self = shift;
	my $mech;
	my $i = 0;
	foreach(@{$self->{links}}) {
		$mech = WWW::Mechanize->new();
		if (defined (eval {$mech->get($_)})){
			if ($self->{user} && $self->{pass}) 
				{$mech->form_number(1);}
			else
				{$mech->form_number(2);}

		my $response = $mech->submit();

		if ($response->is_success && $self->{user} && $self->{pass}) {
			$mech->field("accountid",$self->{user});
			$mech->field("password",$self->{pass});
			$response = $mech->submit();
			if($response->is_success) {
				$mech->form_number(1);
				print "Downloading ${$self->{filenames}}[$i]\n";
				open FILE,">${$self->{filenames}}[$i]" or die "Cannot Open file $!\n";
				select FILE;	binmode FILE;
				print $mech->submit()->decoded_content;
			}
		}
#		else {
#			sleep(60);
#			$mech->form_number(1);
#			open FILE, ">${$self->{filenames}}[$i]" or die "Cannot Open file $!\n";
#			select FILE; binmode FILE;
#			print  $mech->submit()->decoded_content;
#			sleep(1800);
#		}
#		$self->{speed} <= 512 ? sleep(2700) :
#		$self->{speed} <= 1024 ? sleep(1200) :
#		sleep(900);

		select STDOUT;
		close FILE;

		print "${$self->{filenames}}[$i] downloaded! \n";
		$i++;
		$mech = undef;
		}
	else {print "Something unexpected happen\n";}
	}
}


# Save the username and password if have one 
sub save {
	my $self = shift;
	$self->{user} = shift if (@_);
	$self->{pass} = shift if (@_);
	return 0;
}


# Make the directory if does not exist and move to it
sub directory {
	my $self = shift;
  my $name = ${$self->{filenames}}[0];
	$name =~ s/(.part\d)?(.rar|zip|7z)?$//;
	mkdir $name, 0755;	chdir $name;
	return 0;
}

# Decompress the file if is zip, rar or 7z. If is another show message
sub decompress {
	my $self = shift;

	if ($self->type() eq "none") {
		print "Can't decompress this type\n";
		return 0;
	}

	print "Start decompression\n";
	my $dir = abs_path;
	$self->rar($dir) if($self->{type} eq "rar");
	$self->zip($dir) if($self->{type} eq"zip");
	$self->seven($dir) if ($self->{type} eq "seven");
	$self->delete($dir);
	return 1;
}

# Decompress a rar file
sub rar {
	my $self = shift;
	my $dir = shift;
	
	opendir DIR, $dir or die "Cannot open dir: $!\n";

	foreach(sort readdir DIR) {
		if(/rar/) {
			system("rar e $_");
			last;
		}
	}
	close DIR;
}


# Decompress a zip file
sub zip {
	my $self = shift;
	my $dir = shift;

	open DIR, $dir or die "Cannot open dir: $!\n";
	foreach(sort readdir DIR) {
		if(/zip/) {
			system("unzip -v $_");
			last;
		}
	}
	close DIR;
}

# Decompress a 7z file
sub seven {
	my $self = shift;
	my $dir = shift;

	open DIR, $dir or die "Cannot open dir: $!\n";
	foreach(sort readdir DIR) {
		if(/7z/) {
			system("7z e $_");
			last;
		}
	}
	close DIR;
}

# After decompressing the file delete the compressed files 
sub delete {
	my $self = shift;
	my $dir = shift;

	open DIR, $dir or die "Cannot open dir: $!\n";
	foreach(sort readdir DIR) {
		if(/$self->{type}/) {
			unlink;
		}
	}
	close DIR;
}

1;
