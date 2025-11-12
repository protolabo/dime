const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY
);

// Helper function to get actor by auth_user_id
async function getActorByAuthId(authUserId) {
    const { data, error } = await supabase
        .from('actor')
        .select('*, store!actor_id(*)')
        .eq('auth_user_id', authUserId)
        .single();

    if (error) throw error;
    return data;
}

// Client Sign Up
exports.clientSignUp = async (req, res) => {
    try {
        const { email, password, firstName, lastName } = req.body;

        if (!email || !password || !firstName || !lastName) {
            return res.status(400).json({ error: 'Missing required fields' });
        }

        // Create Supabase auth user
        const { data: authData, error: authError } = await supabase.auth.admin.createUser({
            email,
            password,
            email_confirm: true,
            user_metadata: {
                first_name: firstName,
                last_name: lastName,
                user_type: 'client',
                role: 'client'
            }
        });

        if (authError) throw authError;

        // The trigger will automatically create the actor record
        // Wait a moment for the trigger to complete
        await new Promise(resolve => setTimeout(resolve, 500));

        // Fetch the created actor
        const actor = await getActorByAuthId(authData.user.id);

        res.status(201).json({
            message: 'Client account created successfully',
            user: {
                actor_id: actor.actor_id,
                auth_user_id: authData.user.id,
                email: actor.email,
                first_name: actor.first_name,
                last_name: actor.last_name,
                user_type: actor.user_type,
                role: actor.role
            }
        });
    } catch (error) {
        console.error('Client signup error:', error);
        res.status(500).json({ error: error.message });
    }
};

// Commercant Sign Up
exports.commercantSignUp = async (req, res) => {
    try {
        const {
            email,
            password,
            firstName,
            lastName,
            storeName,
            address,
            city,
            postalCode,
            country,
            latitude,
            longitude
        } = req.body;

        if (!email || !password || !firstName || !lastName || !storeName || !address || !city || !postalCode || !country) {
            return res.status(400).json({ error: 'Missing required fields' });
        }

        // Create Supabase auth user
        const { data: authData, error: authError } = await supabase.auth.admin.createUser({
            email,
            password,
            email_confirm: true,
            user_metadata: {
                first_name: firstName,
                last_name: lastName,
                user_type: 'owner',
                role: 'owner'
            }
        });

        if (authError) throw authError;

        // Wait for trigger to create actor
        await new Promise(resolve => setTimeout(resolve, 500));

        // Get the created actor
        const actor = await getActorByAuthId(authData.user.id);

        // Create store record
        const { data: storeData, error: storeError } = await supabase
            .from('store')
            .insert({
                actor_id: actor.actor_id,
                name: storeName,
                address,
                city,
                postal_code: postalCode,
                country,
                latitude: latitude || null,
                longitude: longitude || null,
                created_by: email
            })
            .select()
            .single();

        if (storeError) throw storeError;

        res.status(201).json({
            message: 'Commercant account created successfully',
            user: {
                actor_id: actor.actor_id,
                auth_user_id: authData.user.id,
                email: actor.email,
                first_name: actor.first_name,
                last_name: actor.last_name,
                user_type: actor.user_type,
                role: actor.role,
                store: {
                    store_id: storeData.store_id,
                    name: storeData.name,
                    address: storeData.address,
                    city: storeData.city,
                    postal_code: storeData.postal_code,
                    country: storeData.country
                }
            }
        });
    } catch (error) {
        console.error('Commercant signup error:', error);
        res.status(500).json({ error: error.message });
    }
};

// Client Sign In
exports.clientSignIn = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password required' });
        }

        // Sign in with Supabase
        const { data, error } = await supabase.auth.signInWithPassword({
            email,
            password
        });

        if (error) throw error;

        // Get actor details
        const actor = await getActorByAuthId(data.user.id);

        // Verify user type
        if (actor.user_type !== 'client') {
            return res.status(403).json({ error: 'Invalid account type. Please use the correct sign-in page.' });
        }

        // Update last_login
        await supabase
            .from('actor')
            .update({ last_login: new Date().toISOString() })
            .eq('actor_id', actor.actor_id);

        res.json({
            message: 'Signed in successfully',
            session: data.session,
            user: {
                actor_id: actor.actor_id,
                auth_user_id: actor.auth_user_id,
                email: actor.email,
                first_name: actor.first_name,
                last_name: actor.last_name,
                user_type: actor.user_type,
                role: actor.role,
                last_login: actor.last_login
            }
        });
    } catch (error) {
        console.error('Client signin error:', error);
        res.status(401).json({ error: error.message });
    }
};

// Commercant Sign In
exports.commercantSignIn = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ error: 'Email and password required' });
        }

        // Sign in with Supabase
        const { data, error } = await supabase.auth.signInWithPassword({
            email,
            password
        });

        if (error) throw error;

        // Get actor details with store
        const { data: actor, error: actorError } = await supabase
            .from('actor')
            .select('*, store!actor_id(*)')
            .eq('auth_user_id', data.user.id)
            .single();

        if (actorError) throw actorError;

        // Verify user type
        console.log(actor.user_type);
        if (actor.user_type !== 'owner' && actor.role !== 'employee') {
            return res.status(403).json({ error: 'Invalid account type. Please use the correct sign-in page.' });
        }

        // Update last_login
        await supabase
            .from('actor')
            .update({ last_login: new Date().toISOString() })
            .eq('actor_id', actor.actor_id);

        res.json({
            message: 'Signed in successfully',
            session: data.session,
            user: {
                actor_id: actor.actor_id,
                auth_user_id: actor.auth_user_id,
                email: actor.email,
                first_name: actor.first_name,
                last_name: actor.last_name,
                user_type: actor.user_type,
                role: actor.role,
                staff_id: actor.staff_id,
                last_login: actor.last_login,
                stores: actor.store || []
            }
        });
    } catch (error) {
        console.error('Commercant signin error:', error);
        res.status(401).json({ error: error.message });
    }
};

// Sign Out
exports.signOut = async (req, res) => {
    try {
        const token = req.headers.authorization?.replace('Bearer ', '');

        if (!token) {
            return res.status(401).json({ error: 'No token provided' });
        }

        const { error } = await supabase.auth.admin.signOut(token);

        if (error) throw error;

        res.json({ message: 'Signed out successfully' });
    } catch (error) {
        console.error('Signout error:', error);
        res.status(500).json({ error: error.message });
    }
};

// Get Current User
exports.getCurrentUser = async (req, res) => {
    try {
        const token = req.headers.authorization?.replace('Bearer ', '');

        if (!token) {
            return res.status(401).json({ error: 'No token provided' });
        }

        const { data: { user }, error } = await supabase.auth.getUser(token);

        if (error) throw error;

        // Get actor details
        const { data: actor, error: actorError } = await supabase
            .from('actor')
            .select('*, store!actor_id(*)')
            .eq('auth_user_id', user.id)
            .single();

        if (actorError) throw actorError;

        res.json({
            user: {
                actor_id: actor.actor_id,
                auth_user_id: actor.auth_user_id,
                email: actor.email,
                first_name: actor.first_name,
                last_name: actor.last_name,
                user_type: actor.user_type,
                role: actor.role,
                staff_id: actor.staff_id,
                stores: actor.store || []
            }
        });
    } catch (error) {
        console.error('Get user error:', error);
        res.status(401).json({ error: error.message });
    }
};