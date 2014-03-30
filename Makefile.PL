use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'Geo::Coder::PlaceFinder',
    'VERSION_FROM'	=> 'PlaceFinder.pm', # finds $VERSION
    PREREQ_PM           => { },
);
