package Email::Store::Summary;
use 5.006;
use strict;
use warnings;
our $VERSION = '1.0';
use base 'Email::Store::DBI';
Email::Store::Summary->table("summary");
Email::Store::Summary->columns(All => qw/mail subject original/);
Email::Store::Summary->columns(Primary => qw/mail/);

use Text::Original qw(first_sentence);
sub on_store_order { 80 }

sub on_store {
    my ($self, $mail) = @_;
    my $simple = $mail->simple;
    my $subject = $simple->header("Subject");
    $subject =~ s/^(\s*(re|aw):\s*)+//i; 
    Email::Store::Summary->create({
        mail => $mail->id,
        subject => $subject,
        original => first_sentence($simple->body)
    });
}

sub on_gather_plucene_fields_order { 80 }
# Bet you weren't expecting that!
sub on_gather_plucene_fields {
    my ($self, $mail, $hash) = @_;
    $hash->{subject} = $mail->subject;
}

Email::Store::Summary->has_a(mail => "Email::Store::Mail");
Email::Store::Mail->might_have( 
    summary => "Email::Store::Summary" => qw(subject original) 
);

=head1 NAME

Email::Store::Summary - Provide subject and first-sentence for a mail

=head1 SYNOPSIS

Remember to create the database table:

    % make install
    % perl -MEmail::Store="..." -e 'Email::Store->setup'

And now:

    $mail->subject;
    $mail->original;

=head1 DESCRIPTION

This extension for C<Email::Store> adds the C<summary> table, and exports
the C<subject> and C<original> methods to the C<Email::Store::Mail> class;
C<subject> is the subject of the mail (duh) and C<original> uses
L<Text::Original> to extract the first unquoted sentence of the mail.

=head1 SEE ALSO

L<Email::Store::Mail>, L<Text::Original>.

=head1 AUTHOR

Simon Cozens, C<simon@cpan.org>

This module is distributed under the same terms as Perl itself.

=cut

1;
__DATA__
CREATE TABLE IF NOT EXISTS summary (
    mail varchar(255) NOT NULL PRIMARY KEY,
    subject varchar(255),
    original text
);
