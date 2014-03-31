package IntelliHome::Parser::Mongo;

use Moose;
extends 'IntelliHome::Parser::Base';

use IntelliHome::Schema::Mongo::Trigger;
use IntelliHome::Schema::Mongo::Task;
use IntelliHome::Parser::DB::Mongo;
use Mongoose;

has 'Backend' =>
    ( is => "rw", default => sub { return IntelliHome::Parser::DB::Mongo->new } );

sub prepare {

    my $self = shift;
    Mongoose->db(
        host    => $self->Config->DBConfiguration->{'db_dsn'},
        db_name => $self->Config->DBConfiguration->{'db_name'}
    );

}

sub detectTasks {
    my $self       = shift;
    my $Hypothesis = shift;
    my $hypo       = $Hypothesis->hypo;
    my @Tasks      = IntelliHome::Schema::Mongo::Task->query(
        { node => { host => $self->Node->Host }, status => 1 } )->all;
    if ( scalar @Tasks > 0 ) {

        # $self->Output->info( "Ci sono " . scalar(@Tasks) . " task aperti" );
        foreach my $Task (@Tasks) {

        }

        ##XXX:
        ## Se i task ci sono, vengono processati perchè si suppone questa submission dell'utente sia una parziale risposta
        ## Dunque, si riempie i dati del task precedente,
        ## così l'altro thread può terminare la richiesta e quindi la risposta (se eventualmente genera altri task, ci sarà un motivo)
        ## Si controllano comandi di tipologia di annullamento, in tal caso si pone il task in deletion così il thread si chiude.
    }
    else {
        #   $self->Output->info( "nessun task per " . $self->Node->Host );

    }
}

sub detectTriggers {
    my $self       = shift;
    my $Hypothesis = shift;
    my $hypo       = $Hypothesis->hypo;

    my @Triggers  = $self->Backend->getTriggers();
    my $Satisfied = 0;
    foreach my $item (@Triggers) {

        #Every Trigger cycled here.
        #
        if ( $item->compile($hypo) and $item->satisfy ) {
            $self->run_plugin( $item->plugin, $item->plugin_method, $item );
            $Satisfied++;

            # my $r = $item->regex;
            #  $hypo =~ s/$r//g;    #removes the trigger
            #Checking the trigger needs.

            # foreach my $need ( $item->needs->all ) {
            #     if ( $need->compile($hypo) ) {

            #         $hypo =~ s/$r//g;    #removes the trigger
            #     }
            #     elsif ( $need->forced ) {

            #         #ASkUsers
            #         my @Q = $need->questions->all;
            #         caller->Output->info(
            #             $Q[ int( rand( scalar @Q ) ) ]->ask() );
            #         ###XXX:
            #         ### QUI CREO IL TASK E ASPETTO UN CAMBIAMENTO DI STATO.

            #     }
            # }

        }
        else {
            #   print "No match for trigger.\n";

        }

    }
    return $Satisfied;
}

sub parse {
    my $self       = shift;
    my $caller     = caller;
    my @hypotheses = @_;

    return 0 if scalar @hypotheses < 0;

    foreach my $hypo (@hypotheses) {

      # my $hypo
      #     = $hypotheses[0];  #The first google give us is the more confident

        my $Hypothesis = $self->Backend->newHypo( { hypo => $hypo } );

        $self->detectTasks($Hypothesis);

        last if $self->detectTriggers($Hypothesis) != 0;

    }

}
1;