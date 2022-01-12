-------------------------------------------------------------------------------
--                                                                           --
--                           Percival Source Code                            --
--                Delta NMR Processing and Control Interface                 --
--                                                                           --
--                  Copyright (c) 1993-2007 JEOL USA, Inc.                   --
--                           All Rights Reserved                             --
--                                                                           --
-------------------------------------------------------------------------------

function AUTO_PHASE{ input } return FILE is

    include "common";

    var
        fl        : FILE,
        phase_set : SET,
        widthp    : BOOLEAN := FALSE,
        params    : SET     := remove( input, 1 );

    fl := [FILE](nth( !input, 1 ));

    if size( params ) > 2 then
        widthp := TRUE;
        for i in 3..size( params ) loop
            if type params(i) = [STRING] then
                params(i) := s_eval( params(i) );
            end if;
        end loop;
    end if;

    case size( params ) is
        when 0 =>
            phase_set := autophase( fl );
        when 1 =>
            phase_set := autophase( fl, params(1) );
        when 2 =>
            phase_set := autophase( fl, params(1), params(2) );
        when 4 =>
            phase_set := autophase( fl, params(1), params(2), params(3), params(4) );
    end case;

    if dimension( fl ) = 1 then
        return phase( !fl, phase_set(1), phase_set(2), phase_set(3) );
    else
        return transpose( 
                    phase(
                        transpose(
                            phase( !fl,
                                   phase_set(1),
                                   phase_set(2),
                                   phase_set(5)
                                 )
                        ),
                        phase_set(3),
                        phase_set(4),
                        phase_set(6)
                    )
               );
    end if;

exception e
    when SC~F~OPERATION_ABORTED |
         SC~F~UNHANDLED_FAILURE =>
        if e = SC~F~UNHANDLED_FAILURE and then
           dimension( fl ) = 2 then
            var
                bnds : SET := bounds( fl );
            if compress [UNIT](bnds.FILE_BNDS.start(1)) = [second] or else
               compress [UNIT](bnds.FILE_BNDS.start(2)) = [second] then
                put_line "Auto_Phase failed - Requires both dimensions to be processed";
            end if;
        end if;
        return e;

    when others =>
        put_line {"Auto_Phase failed - ", e};
        return !fl;
end AUTO_PHASE;
