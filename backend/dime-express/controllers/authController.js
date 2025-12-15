const { createClient } = require('@supabase/supabase-js');
const crypto = require('crypto');
const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY
);

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


// Fonction pour encoder le code permanent
function encryptCode(code) {
    const algorithm = 'aes-256-cbc';
    const key = Buffer.from(process.env.ENCRYPTION_KEY, 'hex'); // 32 bytes
    const iv = crypto.randomBytes(16);

    const cipher = crypto.createCipheriv(algorithm, key, iv);
    let encrypted = cipher.update(code, 'utf8', 'hex');
    encrypted += cipher.final('hex');

    return iv.toString('hex') + ':' + encrypted;
}

// Fonction pour décoder le code permanent
function decryptCode(encryptedCode) {
    const algorithm = 'aes-256-cbc';
    const key = Buffer.from(process.env.ENCRYPTION_KEY, 'hex');

    const parts = encryptedCode.split(':');
    const iv = Buffer.from(parts[0], 'hex');
    const encrypted = parts[1];

    const decipher = crypto.createDecipheriv(algorithm, key, iv);
    let decrypted = decipher.update(encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');

    return decrypted;
}
// Générer un code permanent unique
function generatePermanentCode() {
    return crypto.randomBytes(3).toString('hex').toUpperCase();
}

// Ajouter un membre d'équipe
exports.addTeamMember = async (req, res) => {
    try {
        const { firstName, lastName } = req.body;
        const token = req.headers.authorization?.replace('Bearer ', '');

        if (!token) {
            return res.status(401).json({ error: 'No token provided' });
        }

        // Vérifier l'utilisateur connecté
        const { data: { user }, error: userError } = await supabase.auth.getUser(token);
        if (userError) throw userError;

        // Récupérer l'acteur propriétaire
        const owner = await getActorByAuthId(user.id);

        if (owner.user_type !== 'owner') {
            return res.status(403).json({ error: 'Only owners can add team members' });
        }
        // Générer et chiffrer le code permanent
        const permanentCode = generatePermanentCode();
        const encryptedCode = encryptCode(permanentCode);

        const { data: employee, error: employeeError } = await supabase
            .from('actor')
            .insert({
                email: firstName.toLowerCase() + '.' + lastName.toLowerCase() + '@employee.com',
                first_name: firstName,
                last_name: lastName,
                user_type: 'employee',
                role: 'employee',
                encrypted_permanent_code: encryptedCode,
                auth_user_id: null
            })
            .select()
            .single();


        if (employeeError) throw employeeError;

        // Associer l'employé au(x) magasin(s) du propriétaire
        const { data: ownerStores, error: storesError } = await supabase
            .from('store')
            .select('store_id')
            .eq('actor_id', owner.actor_id);

        if (storesError) {
            console.error('Error fetching owner stores:', storesError);
            throw storesError;
        }

        if (ownerStores && ownerStores.length > 0) {
            const storeEmployees = ownerStores.map(store => ({
                store_id: store.store_id,
                actor_id: employee.actor_id,
                added_by: owner.actor_id
            }));
            const { data: insertedData, error: insertError } = await supabase
                .from('store_employee')
                .insert(storeEmployees)
                .select();

            if (insertError) {
                console.error('Error inserting store_employee:', insertError);
                throw insertError;
            }

        } else {
            console.warn('No stores found for owner. Employee not associated with any store.');
        }


        res.status(201).json({
            message: 'Team member added successfully',
            employee: {
                actor_id: employee.actor_id,
                first_name: employee.first_name,
                last_name: employee.last_name,
                permanent_code: permanentCode
            }
        });
    } catch (error) {
        console.error('Add team member error:', error);
        res.status(500).json({ error: error.message });
    }
};

// Connexion employé avec code permanent
exports.employeeSignIn = async (req, res) => {
    try {
        const { code } = req.body;

        if (!code) {
            return res.status(400).json({ error: 'Permanent code required' });
        }

        const { data: employees, error: employeesError } = await supabase
            .from('actor')
            .select('*, store_employee!store_employee_actor_fk(store_id, store:store_id(*))')
            .eq('role', 'employee')
            .not('encrypted_permanent_code', 'is', null);

        if (employeesError || !employees || employees.length === 0) {
            return res.status(401).json({ error: 'Invalid permanent code' });
        }

        let matchedEmployee = null;
        for (const emp of employees) {
            try {
                const decryptedCode = decryptCode(emp.encrypted_permanent_code);
                if (decryptedCode === code.toUpperCase()) {
                    matchedEmployee = emp;
                    break;
                }
            } catch (err) {
                // Ignorer les erreurs de décryptage (codes corrompus)
                continue;
            }
        }

        if (!matchedEmployee) {
            return res.status(401).json({ error: 'Invalid permanent code' });
        }

        const sessionToken = crypto.randomBytes(32).toString('hex');

        await supabase
            .from('actor')
            .update({ last_login: new Date().toISOString() })
            .eq('actor_id', matchedEmployee.actor_id);

        const stores = matchedEmployee.store_employee?.map(se => ({
            store_id: se.store.store_id,
            name: se.store.name,
            address: se.store.address,
            city: se.store.city,
            postal_code: se.store.postal_code,
            country: se.store.country
        })) || [];

        res.json({
            message: 'Signed in successfully',
            session: { access_token: sessionToken },
            user: {
                actor_id: matchedEmployee.actor_id,
                email: matchedEmployee.email,
                first_name: matchedEmployee.first_name,
                last_name: matchedEmployee.last_name,
                user_type: matchedEmployee.user_type,
                role: matchedEmployee.role,
                stores: stores
            }
        });
    } catch (error) {
        console.error('Employee signin error:', error);
        res.status(401).json({ error: 'Authentication failed' });
    }
};

// Récupérer tous les membres de l'équipe
exports.getTeamMembers = async (req, res) => {
    try {
        const token = req.headers.authorization?.replace('Bearer ', '');

        if (!token) {
            return res.status(401).json({ error: 'No token provided' });
        }

        // Vérifier l'utilisateur connecté
        const { data: { user }, error: userError } = await supabase.auth.getUser(token);
        if (userError) throw userError;

        // Récupérer l'acteur propriétaire
        const owner = await getActorByAuthId(user.id);

        if (owner.role !== 'owner') {
            return res.status(403).json({ error: 'Only owners can view team members' });
        }

        // Récupérer tous les employés associés aux magasins du propriétaire
        const { data: ownerStores, error: storesError } = await supabase
            .from('store')
            .select('store_id')
            .eq('actor_id', owner.actor_id);

        if (storesError) throw storesError;

        const storeIds = ownerStores.map(s => s.store_id);

        const { data: storeEmployees, error: employeesError } = await supabase
            .from('store_employee')
            .select('actor_id')
            .in('store_id', storeIds);

        if (employeesError) throw employeesError;

        const employeeIds = [...new Set(storeEmployees.map(se => se.actor_id))];

        const { data: employees, error: fetchError } = await supabase
            .from('actor')
            .select('actor_id, first_name, last_name, email, encrypted_permanent_code, created_at')
            .in('actor_id', employeeIds)
            .eq('role', 'employee')
            .order('created_at', { ascending: false });

        if (fetchError) throw fetchError;

        // Décrypter les codes pour chaque employé
        const employeesWithCodes = employees.map(emp => {
            let permanentCode = null;
            try {
                if (emp.encrypted_permanent_code) {
                    permanentCode = decryptCode(emp.encrypted_permanent_code);
                }
            } catch (err) {
                console.error('Error decrypting code for employee:', emp.actor_id);
            }

            return {
                actor_id: emp.actor_id,
                first_name: emp.first_name,
                last_name: emp.last_name,
                email: emp.email,
                permanent_code: permanentCode,
                created_at: emp.created_at
            };
        });

        res.json({
            employees: employeesWithCodes
        });
    } catch (error) {
        console.error('Get team members error:', error);
        res.status(500).json({ error: error.message });
    }
};




