disk=$1
shift
while (($#))
do
    decb copy -2b $1 $disk,$( echo $1 | sed -e 's|.*/||' | tr 'a-z' 'A-Z' )
    shift
done

